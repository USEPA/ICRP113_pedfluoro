library(shinydashboard)
library(shiny)
library(readxl)
library(purrr)
library(dplyr)
library(stringr)
library(shinyWidgets) # For pickerInput
library(DT)           # For interactive tables

# Read in Files -----------------------------------------------------------

# Path to your file
path <- file.path("data", "MBS_DRAFT.xlsx")
# Read all sheets into one data frame
MBS <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map_df(~read_excel(path, sheet = .x), .id = "sheet_name")

# Path to your file
path <- file.path("data", "VCUG_DRAFT.xlsx")
# Read all sheets into one data frame
VCUG <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map_df(~read_excel(path, sheet = .x), .id = "sheet_name")

# Path to your file
path <- file.path("data", "LGI_DRAFT.xlsx")
# Read all sheets into one data frame
LGI <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map_df(~read_excel(path, sheet = .x), .id = "sheet_name")

# Path to your file
path <- file.path("data", "UGI_DRAFT.xlsx")
# Read all sheets into one data frame
UGI <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map_df(~read_excel(path, sheet = .x), .id = "sheet_name")

all <- rbind(UGI, VCUG, LGI, MBS)
all <- all %>% mutate(
  KAP_ref = ifelse(str_detect(sheet_name, "KAP"), "KAP", "Reference"),
  phantom_sex = ifelse(str_detect(Phantom, "f"), "female", "male"),
  phantom_age = ifelse(substr(Phantom, 1, 2) == "00", "newborn", 
                       ifelse(substr(Phantom, 1, 2) == "01", "1 year", 
                              ifelse(substr(Phantom, 1, 2) == "05", "5 years",
                                     ifelse(substr(Phantom, 1, 2) == "10", "10 years",
                                            "15 years"))))
)




# -----------------------------------------------------------------------------
# Phantom images folder mapping
# -----------------------------------------------------------------------------
# Set this to the absolute path where your phantom images live.
# If they are within your app at ./www/phantoms, you can keep/adjust the path below.
phantom_dir_fs <- normalizePath(file.path(getwd(), "www", "phantoms"), mustWork = FALSE)

# Serve that folder at URL path /phantoms/ (works even in gadgets)
if (dir.exists(phantom_dir_fs)) {
  shiny::addResourcePath("phantoms", phantom_dir_fs)
} else {
  warning("Phantom images folder not found: ", phantom_dir_fs)
}

# Helper to list images (filenames only)
list_phantom_images <- function() {
  if (!dir.exists(phantom_dir_fs)) return(character(0))
  list.files(
    path = phantom_dir_fs,
    pattern = "\\.(png|jpg|jpeg|gif)$",
    ignore.case = TRUE,
    full.names = FALSE
  )
}

# -----------------------------------------------------------------------------
# UI
# -----------------------------------------------------------------------------
ui <- dashboardPage( skin = "black",  
  dashboardHeader(title = "Dose Assesment from Common Pediatric Examinations",
                  titleWidth = 1500),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
  
      tags$head(tags$style(HTML("
    /* Left-align the header title */
      .main-header .logo {
        text-align: left !important;"))),
    
    fluidRow(
      # LEFT: Inputs
      column(
        width = 3,height = 700,
        box(width = NULL, title = "Inputs", height = 700,solidHeader = TRUE,
            selectInput("procedure", "Procedure:",
                        choices = c("VCUG" = "VCUG",
                                    "MBS"  = "MBS",
                                    "LGI"  = "LGI",
                                    "UGI"  = "UGI"), selected = "VCUG"),
            radioButtons("sex", "Sex:",
                         choices = c("male" = "male",
                                     "female" = "female"), selected = "female"),
            radioButtons("disease", "Disease:",
                         choices = c("normal" = "normal",
                                     "abnormal" = "abnormal"), selected = "normal"),
            selectInput("age", "Age:",
                        choices = c("newborn" = "newborn",
                                    "1 year"  = "1 year",
                                    "5 years" = "5 years",
                                    "10 years"= "10 years",
                                    "15 years"= "15 years"), selected = "1 year"),
            selectInput("KVP", "Tube Potential (kVp):",
                        choices = c(60, 80, 110), selected = 60),
            selectInput("HVL", "HVL (mm Al):",
                        choices = c("2.5"    = "2.5",
                                    "5.7448" = "5.7447999999999997",
                                    "6.3535" = "6.3535000000000004",
                                    "2.9"    = "2.9",
                                    "7.702"  = "7.702",
                                    "8.502"  = "8.5020000000000007",
                                    "3.9"    = "3.9",
                                    "7.85"   = "7.85",
                                    "9.9905" = "9.9905000000000008"), selected = "5.7447999999999997"),
            radioButtons("sheet", "KAP or Reference?:",
                         choices = c("KAP" = "KAP",
                                     "Reference" = "Reference"), selected = "KAP"),
            pickerInput(
              inputId  = "organs",
              label    = "Organs to display:",
              choices  = NULL,         # filled at server startup
              selected = NULL,         # filled at server startup
              multiple = TRUE,
              options = pickerOptions(
                actionsBox = TRUE,     # Select/Deselect All
                liveSearch = TRUE
              )
            )
        )
      ),
      
      # CENTER: Summary + Table (DT)
      column(
        width = 6,height = 700,
        box(width = NULL, solidHeader = TRUE, title = "Selected Parameters & Filtered Results",height = 700,
            DTOutput("filtered_table")
        )
      ),
      
      # RIGHT: Phantoms carousel
      column(
        width = 3,height = 700,
        box(solidHeader = TRUE, title = "Phantoms", width = NULL, height = 700,
            div(style = "text-align:center; margin-bottom: 6px;",
                actionButton("prev_img", label = NULL, icon = icon("chevron-left")),
                actionButton("next_img", label = NULL, icon = icon("chevron-right"))
            ),
            uiOutput("phantom_img"),
            br(),
            uiOutput("phantom_counter")
        )
      )
    )
  )
)

# -----------------------------------------------------------------------------
# SERVER
# -----------------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Discover organ columns (from Adrenals to either Remainder or Effective Dose)
  observeEvent(TRUE, {
    nm <- names(all)
    start <- which(nm == "Adrenals")
    # choose end column robustly
    end <- if ("Remainder" %in% nm) which(nm == "Remainder") else which(nm == "Effective Dose")
    organ_cols <- if (length(start) == 1 && length(end) == 1 && start <= end) nm[start:end] else character(0)
    
    updatePickerInput(session, "organs", choices = organ_cols, selected = organ_cols)
  }, once = TRUE)
 
  # Filter and select columns
  filtered_data <- reactive({
    x <- all %>%
      filter(
        KAP_ref            == input$sheet,
        Procedure          == input$procedure,
        `Disease State`    == input$disease,
        phantom_sex        == input$sex,
        phantom_age        == input$age,
        `Peak Potential`   == as.character(input$KVP),
        HVL                == input$HVL
      )
    
    # group columns + user-selected organs
    sel <- unique(c("Field #", input$organs, "Effective Dose"))
    
    y <- x %>%
      select(any_of(sel))
    
    # Round numeric organ columns and Effective Dose if present
    if (!is.null(input$organs) && length(input$organs) > 0) {
      y <- y %>% mutate(across(intersect(names(y), input$organs), ~ round(as.numeric(.), 2)))
    }
    if ("Effective Dose" %in% names(y)) {
      y$`Effective Dose` <- round(as.numeric(y$`Effective Dose`), 2)
    }
    y
  })
  
  # Table display with DT
  output$filtered_table <- renderDT({
    datatable(
      filtered_data(),
      options = list(scrollX = TRUE, autoWidth = TRUE, rownames = FALSE, pageLength = 12)
      
    )
  })
  
  # -----------------------------------------------------------------------------
  # Phantoms carousel
  # -----------------------------------------------------------------------------
  phantom_images <- reactiveVal(list_phantom_images())
  current_idx    <- reactiveVal(1L)
  
  observeEvent(input$prev_img, {
    n <- length(phantom_images()); if (n == 0) return(NULL)
    i <- current_idx(); current_idx(if (i <= 1L) n else i - 1L)
  })
  
  observeEvent(input$next_img, {
    n <- length(phantom_images()); if (n == 0) return(NULL)
    i <- current_idx(); current_idx(if (i >= n) 1L else i + 1L)
  })
  
  output$phantom_img <- renderUI({
    imgs <- phantom_images()
    if (length(imgs) == 0) {
      return(tags$em("No images found in: ", phantom_dir_fs))
    }
    i <- current_idx()
    i <- max(1L, min(i, length(imgs)))
    
    # URL path served by addResourcePath. URL-encode to handle spaces/special chars.
    src <- paste0("phantoms/", URLencode(imgs[i], reserved = TRUE))
    
    # Optional: verify that the file exists at the filesystem path
    underlying <- file.path(phantom_dir_fs, imgs[i])
    if (!file.exists(underlying)) {
      return(tags$div(
        tags$strong("Image file not found: "),
        tags$code(underlying)
      ))
    }
    
    tags$img(src = src, style = "max-width: 90%; height: auto;")
  })
  
  output$phantom_counter <- renderUI({
    imgs <- phantom_images()
    if (length(imgs) == 0) return(NULL)
    i <- current_idx()
    tags$small(sprintf("Image %d of %d: %s", i, length(imgs), imgs[i]))
  })
}

# Run the app
#shinyApp(ui, server)
vwr <- dialogViewer(' ', width = 3200, height = 7400)
runGadget(shinyApp(ui = ui, server = server), viewer = vwr)