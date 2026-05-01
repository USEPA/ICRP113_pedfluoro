
##Dose Assesment from Common Pediatric Diagnostic Fluoroscopic Examinations##

# ---- Packages ----
library(shinydashboard)
library(shiny)
library(readxl)
library(purrr)
library(dplyr)
library(stringr)
library(shinyWidgets) # pickerInput
library(DT)           # interactive tables

# ---- Data: read all sheets from multiple workbooks ----
read_workbook <- function(path) {
  excel_sheets(path) |>
    set_names() |>
    map_df(~ read_excel(path, sheet = .x), .id = "sheet_name")
}

MBS  <- read_workbook(file.path("data", "MBS_DRAFT.xlsx"))
VCUG <- read_workbook(file.path("data", "VCUG_DRAFT.xlsx"))
LGI  <- read_workbook(file.path("data", "LGI_DRAFT.xlsx"))
UGI  <- read_workbook(file.path("data", "UGI_DRAFT.xlsx"))

all <- bind_rows(UGI, VCUG, LGI, MBS) |>
  mutate(
    KAP_ref     = if_else(str_detect(sheet_name, "KAP"), "KAP", "Reference"),
    phantom_sex = if_else(str_detect(Phantom, "f"), "female", "male"),
    phantom_age = case_when(
      substr(Phantom, 1, 2) == "00" ~ "newborn",
      substr(Phantom, 1, 2) == "01" ~ "1 year",
      substr(Phantom, 1, 2) == "05" ~ "5 years",
      substr(Phantom, 1, 2) == "10" ~ "10 years",
      TRUE ~ "15 years"
    )
  )

# ---- Phantom Images ----
phantom_dir_fs <- normalizePath(file.path(getwd(), "www", "phantoms"), mustWork = FALSE)
if (dir.exists(phantom_dir_fs)) {
  shiny::addResourcePath("phantoms", phantom_dir_fs)
} else {
  warning("Phantom images folder not found: ", phantom_dir_fs)
}

list_phantom_images <- function() {
  if (!dir.exists(phantom_dir_fs)) return(character(0))
  list.files(
    path = phantom_dir_fs,
    pattern = "\\.(png|jpg|jpeg|gif)$",
    ignore.case = TRUE,
    full.names = FALSE
  )
}

# ---- UI ----
app_styles <- "
  .phantom-img-wrap {
    width: 100%; height: 180px; display: flex; align-items: center; justify-content: center;
    border: 1px solid #ccc; border-radius: 4px; background: #fff; overflow: hidden;
  }
  .phantom-img { max-width: 100%; max-height: 100%; object-fit: contain; }
  .main-header .logo { text-align: left !important; }
  .field-title {
    font-weight: 600; text-align: center; margin-bottom: 6px; background: #f0f0f0;
    border-radius: 4px; padding: 4px 8px;
  }
"

ui <- dashboardPage(
  skin = "black",
  dashboardHeader(
    title = "Dose Assesment from Common Pediatric Diagnostic Fluoroscopic Examinations",
    titleWidth = 1500
  ),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$head(tags$style(HTML(app_styles))),
    fluidRow(
      # ---- Left: Inputs ----
      column(
        width = 3,
        height = 1100,
        box(
          width = NULL, height = 1100, title = "Inputs", solidHeader = TRUE,
          selectInput(
            "procedure", "Examination:",
            choices = c(
              "VCUG (Voiding Cystourethrogram)" = "VCUG",
              "MBS (Modified Barium Swallow)"   = "MBS",
              "LGI (Lower Gastrointestinal)"     = "LGI",
              "UGI (Upper Gastrointestinal)"     = "UGI"
            ),
            selected = "VCUG"
          ),
          radioButtons("sex", "Sex:",
                       choices = c("Male" = "male", "Female" = "female"),
                       selected = "female", inline = TRUE
          ),
          selectInput("age", "Age:",
                      choices = c("newborn","1 year","5 years","10 years","15 years"),
                      selected = "1 year"
          ),
          selectInput("disease", "Clinical Finding:",
                      choices = c("normal" = "normal", "abnormal" = "abnormal"),
                      selected = "normal"
          ),
          hr(),
          radioButtons("spectrum_mode", "Spectrum Input Mode:",
                       choices = c("Preset" = "preset", "Custom" = "custom"),
                       selected = "preset", inline = TRUE
          ),
          conditionalPanel(
            condition = "input.spectrum_mode == 'preset'",
            selectInput(
              "xray_spectrum", "X-Ray Spectrum (kVp, HVL mm Al):",
              choices = c(
                "60, 2.5"     = "60|2.5",
                "60, 5.7448"  = "60|5.7447999999999997",
                "60, 6.3535"  = "60|6.3535000000000004",
                "80, 2.9"     = "80|2.9",
                "80, 7.702"   = "80|7.702",
                "80, 8.502"   = "80|8.5020000000000007",
                "110, 3.9"    = "110|3.9",
                "110, 7.85"   = "110|7.85",
                "110, 9.9905" = "110|9.9905000000000008"
              ),
              selected = "60|2.5"
            )
          ),
          conditionalPanel(
            condition = "input.spectrum_mode == 'custom'",
            tagList(
              sliderInput("kvp_slider", "kVp:", min = 60, max = 120, value = 60, step = 1),
              sliderInput("hvl_slider", "HVL (mm Al):", min = 2.5, max = 10, value = 2.5, step = 0.01)
            )
          ),
          selectInput("flouro_rate", HTML("Flouroscopy Frame Rate (s<sup>-1</sup>):"),
                      choices = c(7.5, 15, 30, 45), selected = 15),
          textInput("b_spot", "\u03B2 Spot Factor", value = "30"),
          radioButtons(
            "kap_dose_type", "Available Dose Metric:",
            choiceNames  = list(HTML("KAP (Gy \u22C5 cm<sup>2</sup>)"), HTML("Dose at the Reference Point (Gy)")),
            choiceValues = list("KAP", "Dose")
          ),
          uiOutput("kap_dose_value"),
          br(),
          actionButton("gen_field_labels", "Submit")
        )
      ),
      
      # ---- Center: Phantom Grid/Mods ----
      column(
        width = 6, height = 1100,
        box(
          width = NULL, height = 1100, title = "Reference Protocol", solidHeader = TRUE,
          column(
            width = 12,
            fluidRow(
              column(6, tagList(textOutput("phantom_gallery_title", inline = TRUE))),
              column(6, radioButtons("modify", NULL,
                                     choices = c("Accept Protocol" = "yes", "Modify" = "no"),
                                     selected = "yes", inline = TRUE
              ))
            ),
            fluidRow(column(12, uiOutput("phantom_gallery"))),
            fluidRow(column(12, tags$hr(), uiOutput("field_summary")))
          )
        )
      ),
      
      # ---- Right: Tables and Export ----
      column(
        width = 3, height = 1100,
        box(
          title = "Tabular data", width = NULL, height = 1100, solidHeader = TRUE,
          tabsetPanel(
            id = "right_tabs",
            tabPanel("Total Dose", DT::dataTableOutput("fields_table"),
                     style = "height:700px; overflow-y: scroll; overflow-x: scroll;"),
            tabPanel("Field Dose", DT::dataTableOutput("organs_table"),
                     style = "height:700px; overflow-y: scroll; overflow-x: scroll;"),
            tabPanel("Dose Coefficient")
          ),
          br(),
          downloadButton("export_csv", "Export")
        )
      )
    )
  )
)

# ---- Server ----
server <- function(input, output, session) {
  
  rv <- reactiveValues(
    custom_fields  = NULL,   # data.frame(Field, TPT, Radiographs)
    custom_applied = FALSE
  )
  
  # Parse "kvp|hvl"
  parse_spectrum <- function(val) {
    if (is.null(val) || !is.character(val) || !nzchar(val) || !grepl("\\|", val)) return(NULL)
    parts <- strsplit(val, "\\|")[[1]]
    if (length(parts) < 2) return(NULL)
    list(kvp = parts[1], hvl = parts[2])
  }
  
  # Keep sliders synced to preset
  observeEvent(list(input$xray_spectrum, input$spectrum_mode), {
    req(identical(input$spectrum_mode, "preset"))
    s <- parse_spectrum(input$xray_spectrum); req(!is.null(s))
    kvp_num <- suppressWarnings(as.numeric(s$kvp))
    hvl_num <- suppressWarnings(as.numeric(s$hvl))
    if (!is.na(kvp_num)) updateSliderInput(session, "kvp_slider", value = kvp_num)
    if (!is.na(hvl_num)) updateSliderInput(session, "hvl_slider", value = hvl_num)
  }, ignoreInit = TRUE)
  
  # Single numeric input for KAP/Dose
  output$kap_dose_value <- renderUI({
    textInput("kap_dose_input", label = paste(if (identical(input$kap_dose_type, "KAP")) "KAP" else "Dose", "value"),
              value = "0.15", placeholder = "Enter a number")
  })
  kap_value  <- reactive({ if (!identical(input$kap_dose_type, "KAP"))  return(NA_real_); suppressWarnings(as.numeric(input$kap_dose_input)) })
  dose_value <- reactive({ if (!identical(input$kap_dose_type, "Dose")) return(NA_real_); suppressWarnings(as.numeric(input$kap_dose_input)) })
  
  # ---- Subset DF by inputs (exact spectrum for preset; keep all spectra for custom) ----
  exam_subset <- reactive({
    req(input$procedure, input$sex, input$age, input$kap_dose_type)
    
    df <- all |>
      filter(Procedure == input$procedure, phantom_sex == input$sex, phantom_age == input$age)
    
    if (identical(input$spectrum_mode, "preset")) {
      s <- parse_spectrum(input$xray_spectrum)
      if (!is.null(s)) {
        df <- df |>
          filter(`Peak Potential` == s$kvp, HVL == s$hvl)
      }
    } # custom: keep all spectra rows; interpolate later
    
    df <- df |>
      filter(is.na(sheet_name) | tolower(trimws(sheet_name)) != "r.err") |>
      filter(if (identical(input$kap_dose_type, "KAP")) KAP_ref == "KAP" else KAP_ref == "Reference")
    
    df
  })
  
  # ---- Tables: Organ-by-field ----
  output$organs_table <- renderDT({
    req(input$gen_field_labels > 0)
    mat <- dose_per_field_org()
    if (!is.matrix(mat) || nrow(mat) == 0) {
      return(datatable(data.frame(Message = "No organ data for current selection", check.names = FALSE),
                       options = list(dom = 't'), rownames = FALSE))
    }
    df <- data.frame(Field = rownames(mat), as.data.frame(mat, stringsAsFactors = FALSE), check.names = FALSE)
    num_cols <- vapply(df, is.numeric, logical(1))
    df[num_cols] <- lapply(df[num_cols], function(x) round(x, 3))
    datatable(df, options = list(scrollX = TRUE, scrollY = TRUE, autoWidth = TRUE, dom = 'tip'), rownames = FALSE)
  })
  
  # ---- Tables: Sum across fields ----
  output$fields_table <- renderDT({
    req(input$gen_field_labels > 0)
    mat <- dose_per_field_org()
    if (!is.matrix(mat) || nrow(mat) == 0) {
      return(datatable(data.frame(Message = "No data for current selection", check.names = FALSE),
                       options = list(dom = 't'), rownames = FALSE))
    }
    sums <- colSums(mat, na.rm = TRUE)
    df <- data.frame(Organ = names(sums), `Dose Sum` = as.numeric(sums), check.names = FALSE)
    num_cols <- vapply(df, is.numeric, logical(1))
    df[num_cols] <- lapply(df[num_cols], function(x) round(x, 3))
    datatable(df, colnames = c("Organ", "Dose (mGy)"),
              options = list(scrollX = TRUE, scrollY = TRUE, autoWidth = TRUE, dom = 'tip', paging = FALSE),
              rownames = FALSE)
  })
  
  # ---- CSV export ----
  output$export_csv <- downloadHandler(
    filename = function() {
      suffix <- switch(input$right_tabs, "Total Dose" = "_total-dose", "Field Dose" = "_field-dose", "_export")
      paste0("tables", suffix, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      mat <- dose_per_field_org()
      if (identical(input$right_tabs, "Total Dose")) {
        df <- if (is.matrix(mat) && nrow(mat) > 0) {
          sums <- colSums(mat, na.rm = TRUE)
          out  <- data.frame(Organ = names(sums), Dose_mGy = as.numeric(sums), check.names = FALSE)
          num_cols <- vapply(out, is.numeric, logical(1))
          out[num_cols] <- lapply(out[num_cols], function(x) round(x, 4))
          out
        } else data.frame(Message = "No data for current selection", check.names = FALSE)
        utils::write.csv(df, file, row.names = FALSE)
      } else if (identical(input$right_tabs, "Field Dose")) {
        df <- if (is.matrix(mat) && nrow(mat) > 0) {
          out <- data.frame(Field = rownames(mat), as.data.frame(mat, stringsAsFactors = FALSE), check.names = FALSE)
          num_cols <- vapply(out, is.numeric, logical(1))
          out[num_cols] <- lapply(out[num_cols], function(x) round(x, 4))
          out
        } else data.frame(Message = "No organ data for current selection", check.names = FALSE)
        utils::write.csv(df, file, row.names = FALSE)
      } else {
        utils::write.csv(data.frame(Message = "No export available for this tab", check.names = FALSE),
                         file, row.names = FALSE)
      }
    }
  )
  
  # ---- Interpolation (Eq. 3.6) ----
  lin_interp <- function(x, x0, x1, y0, y1) {
    if (!is.finite(x0) || !is.finite(x1) || x0 == x1) return(y0)
    y0 + (x - x0) * (y1 - y0) / (x1 - x0)
  }
  
  interpolate_hvl_1d <- function(sub_k, org_cols, hvl_target, hvl_col = "hvl_num") {
    if (nrow(sub_k) == 0) return(NULL)
    hvls <- sort(unique(sub_k[[hvl_col]][!is.na(sub_k[[hvl_col]])]))
    if (length(hvls) == 0) return(NULL)
    
    if (any(abs(hvls - hvl_target) < 1e-10)) {
      row <- sub_k %>% filter(abs(.data[[hvl_col]] - hvl_target) < 1e-10) %>% slice(1)
      return(suppressWarnings(as.numeric(row[, org_cols, drop = TRUE])))
    }
    
    lower_set <- hvls[hvls < hvl_target]
    upper_set <- hvls[hvls > hvl_target]
    hvl_low   <- if (length(lower_set)) max(lower_set) else NA_real_
    hvl_high  <- if (length(upper_set)) min(upper_set) else NA_real_
    
    if (!is.finite(hvl_low) && is.finite(hvl_high)) {
      row <- sub_k %>% filter(abs(.data[[hvl_col]] - hvl_high) < 1e-10) %>% slice(1)
      return(suppressWarnings(as.numeric(row[, org_cols, drop = TRUE])))
    }
    if (!is.finite(hvl_high) && is.finite(hvl_low)) {
      row <- sub_k %>% filter(abs(.data[[hvl_col]] - hvl_low) < 1e-10) %>% slice(1)
      return(suppressWarnings(as.numeric(row[, org_cols, drop = TRUE])))
    }
    
    row_low  <- sub_k %>% filter(abs(.data[[hvl_col]] - hvl_low)  < 1e-10) %>% slice(1)
    row_high <- sub_k %>% filter(abs(.data[[hvl_col]] - hvl_high) < 1e-10) %>% slice(1)
    dc_low   <- suppressWarnings(as.numeric(row_low[,  org_cols, drop = TRUE]))
    dc_high  <- suppressWarnings(as.numeric(row_high[, org_cols, drop = TRUE]))
    lin_interp(hvl_target, hvl_low, hvl_high, dc_low, dc_high)
  }
  
  interpolate_bilinear_field <- function(sub_f, org_cols, kvp_target, hvl_target,
                                         kvp_col = "kvp_num", hvl_col = "hvl_num") {
    if (nrow(sub_f) == 0) return(NULL)
    
    exact <- sub_f %>%
      filter(abs(.data[[kvp_col]] - kvp_target) < 1e-10,
             abs(.data[[hvl_col]] - hvl_target) < 1e-10) %>%
      slice(1)
    if (nrow(exact) == 1) {
      return(suppressWarnings(as.numeric(exact[, org_cols, drop = TRUE])))
    }
    
    kvps <- sort(unique(sub_f[[kvp_col]][!is.na(sub_f[[kvp_col]])]))
    if (length(kvps) == 0) return(NULL)
    lower_k <- kvps[kvps <= kvp_target]
    upper_k <- kvps[kvps >= kvp_target]
    kvp_low  <- if (length(lower_k)) max(lower_k) else NA_real_
    kvp_high <- if (length(upper_k)) min(upper_k) else NA_real_
    
    if (!is.finite(kvp_high) && is.finite(kvp_low)) {
      sub_k <- sub_f %>% filter(abs(.data[[kvp_col]] - kvp_low) < 1e-10)
      return(interpolate_hvl_1d(sub_k, org_cols, hvl_target, hvl_col))
    }
    if (!is.finite(kvp_low) && is.finite(kvp_high)) {
      sub_k <- sub_f %>% filter(abs(.data[[kvp_col]] - kvp_high) < 1e-10)
      return(interpolate_hvl_1d(sub_k, org_cols, hvl_target, hvl_col))
    }
    
    sub_low  <- sub_f %>% filter(abs(.data[[kvp_col]] - kvp_low)  < 1e-10)
    sub_high <- sub_f %>% filter(abs(.data[[kvp_col]] - kvp_high) < 1e-10)
    
    v_low  <- interpolate_hvl_1d(sub_low,  org_cols, hvl_target, hvl_col)
    v_high <- interpolate_hvl_1d(sub_high, org_cols, hvl_target, hvl_col)
    
    if (is.null(v_low) && is.null(v_high)) return(NULL)
    if (is.null(v_low))  return(v_high)
    if (is.null(v_high)) return(v_low)
    
    lin_interp(kvp_target, kvp_low, kvp_high, v_low, v_high)
  }
  
  # ---- Per-field info for gallery controls ----
  fields_info <- reactive({
    df <- exam_subset()
    if (nrow(df) == 0) return(data.frame(Field = numeric(0), TPT = numeric(0), Radiographs = numeric(0)))
    rn <- names(df)
    
    fld_candidates <- rn[tolower(rn) %in% c("field #","field#","field no","field number","field","Field #")]
    fld_col <- if (length(fld_candidates) > 0) fld_candidates[1] else NULL
    
    ft_candidates <- rn[grepl("\\bfield[[:space:]]*time\\b", tolower(rn))]
    tpt_col <- if (length(ft_candidates) > 0) ft_candidates[1] else {
      tpt_candidates <- rn[grepl("total\\s*procedure\\s*time", tolower(rn))]
      if (length(tpt_candidates) > 0) tpt_candidates[1] else NULL
    }
    
    rad_candidates <- rn[grepl("\\bradigraph", tolower(rn)) | grepl("^\\s*#?\\s*of\\s*radigraphs\\s*$", tolower(rn))]
    rad_col <- if (length(rad_candidates) > 0) rad_candidates[1] else NULL
    
    idx <- seq_len(nrow(df))
    if (!is.null(fld_col)) idx <- order(suppressWarnings(as.numeric(df[[fld_col]])), na.last = TRUE)
    idx <- head(idx, 12)
    
    parse_num <- function(x) {
      x <- trimws(as.character(x))
      x[x %in% c("", "NA", "N/A", "na", "n/a", "-", "—", "r.err")] <- NA_character_
      suppressWarnings(readr::parse_number(x))
    }
    
    TPT_vals <- if (!is.null(tpt_col)) parse_num(df[[tpt_col]])[idx] else rep(NA_real_, length(idx))
    RAD_vals <- if (!is.null(rad_col)) parse_num(df[[rad_col]])[idx] else rep(NA_real_, length(idx))
    
    data.frame(
      Field       = if (!is.null(fld_col)) suppressWarnings(as.numeric(df[[fld_col]]))[idx] else seq_along(idx),
      TPT         = TPT_vals,
      Radiographs = RAD_vals,
      check.names = FALSE
    )
  })
  
  # ---- Eqn 3.1: per-field spot time ----
  t_spot_f <- reactive({
    b  <- suppressWarnings(as.numeric(input$b_spot))
    fr <- suppressWarnings(as.numeric(input$flouro_rate))
    if (is.na(b) || is.na(fr) || fr == 0) return(numeric(0))
    
    if (isTRUE(rv$custom_applied) && !is.null(rv$custom_fields) && nrow(rv$custom_fields) > 0) {
      dfc  <- rv$custom_fields[order(rv$custom_fields$Field), , drop = FALSE]
      rads <- suppressWarnings(as.numeric(dfc$Radiographs))
      out  <- rads * (b / fr)
      return(c(head(out, 12), rep(NA_real_, max(0, 12 - length(out)))))
    }
    
    df <- exam_subset()
    if (nrow(df) == 0 || !("# of Radigraphs" %in% names(df))) return(numeric(0))
    idx <- seq_len(nrow(df))
    if ("Field #" %in% names(df)) idx <- order(suppressWarnings(as.numeric(df[["Field #"]])), na.last = TRUE)
    n_rad <- suppressWarnings(as.numeric(df[["# of Radigraphs"]]))[idx]
    out   <- n_rad * (b / fr)
    c(head(out, 12), rep(NA_real_, max(0, 12 - length(out))))
  })
  
  t_spot_total   <- reactive({ sum(head(t_spot_f(), 12), na.rm = TRUE) })
  
  # ---- Eqn 3.2: total fluoroscopy time ----
  t_fluoro_total <- reactive({
    if (rv$custom_applied && !is.null(rv$custom_fields))
      return(sum(suppressWarnings(as.numeric(rv$custom_fields$TPT)), na.rm = TRUE))
    
    df <- exam_subset()
    if (nrow(df) == 0) return(NA_real_)
    vals <- suppressWarnings(as.numeric(df[["Field Time"]]))
    if ("Field #" %in% names(df)) {
      idx  <- order(suppressWarnings(as.numeric(df[["Field #"]])))
      vals <- vals[idx]
    }
    sum(head(vals, 12), na.rm = TRUE)
  })
  
  # ---- Eqn 3.3: weighting factor ----
  wf <- reactive({
    if (isTRUE(rv$custom_applied) && !is.null(rv$custom_fields) && nrow(rv$custom_fields) > 0) {
      dfc      <- rv$custom_fields[order(rv$custom_fields$Field), , drop = FALSE]
      tpt_vals <- suppressWarnings(as.numeric(dfc$TPT))
      tspotf   <- head(t_spot_f(), 12)
      m        <- min(length(tpt_vals), length(tspotf))
      if (m == 0) return(numeric(0))
      denom <- t_fluoro_total() + t_spot_total()
      if (is.na(denom) || denom == 0) return(numeric(0))
      num <- tpt_vals[seq_len(m)] + tspotf[seq_len(m)]
      return(round(num / denom, 2))
    }
    
    df <- exam_subset()
    if (nrow(df) == 0) return(numeric(0))
    rn <- names(df)
    ft_candidates <- rn[grepl("\\bfield[[:space:]]*time\\b", tolower(rn))]
    if (length(ft_candidates) == 0) return(numeric(0))
    tpt_col <- ft_candidates[1]
    
    idx <- seq_len(nrow(df))
    fld_candidates <- rn[tolower(rn) %in% c("field #","field#","field no","field number","field")]
    if (length(fld_candidates) > 0) {
      fld_col <- fld_candidates[1]
      idx     <- order(suppressWarnings(as.numeric(df[[fld_col]])), na.last = TRUE)
    }
    
    tpt_vals <- suppressWarnings(as.numeric(df[[tpt_col]]))[idx] |> head(12)
    tspotf   <- head(t_spot_f(), 12)
    m <- min(length(tpt_vals), length(tspotf))
    if (m == 0) return(numeric(0))
    denom <- t_fluoro_total() + t_spot_total()
    if (is.na(denom) || denom == 0) return(numeric(0))
    num <- tpt_vals[seq_len(m)] + tspotf[seq_len(m)]
    round(num / denom, 2)
  })
  
  # ---- Eqn 3.4: per-field organ doses (uses interpolated coefficients) ----
  dose_per_field_org <- reactive({
    df <- exam_subset()
    if (nrow(df) == 0) return(matrix(numeric(0), nrow = 0, ncol = 0))
    rn <- names(df)
    
    fld_candidates <- rn[tolower(rn) %in% c("field #","field#","field no","field number","field","Field #")]
    fld_col <- if (length(fld_candidates) > 0) fld_candidates[1] else NULL
    
    idx <- seq_len(nrow(df))
    if (!is.null(fld_col)) idx <- order(suppressWarnings(as.numeric(df[[fld_col]])), na.last = TRUE)
    idx <- head(idx, 12)
    
    eff_candidates <- rn[grepl("^\\s*effective\\s*dose\\s*$", rn, ignore.case = TRUE)]
    if (length(eff_candidates) == 0) return(matrix(numeric(0), nrow = 0, ncol = 0))
    eff_col <- eff_candidates[1]
    
    start_idx <- which(rn == "Adrenals")[1]
    rem_idx   <- if ("Remainder" %in% rn) which(rn == "Remainder")[1] else NA_integer_
    ed_idx    <- if ("Effective Dose" %in% rn) which(rn == "Effective Dose")[1] else NA_integer_
    end_idx   <- if (is.finite(rem_idx)) rem_idx else if (is.finite(ed_idx) && ed_idx > start_idx) ed_idx - 1 else NA_integer_
    organ_cols <- character(0)
    if (is.finite(start_idx) && is.finite(end_idx) && start_idx <= end_idx) organ_cols <- rn[start_idx:end_idx]
    
    if (!("HVL" %in% names(df)) || !("Peak Potential" %in% names(df))) return(matrix(numeric(0), nrow = 0, ncol = 0))
    df <- df |>
      mutate(kvp_num = suppressWarnings(as.numeric(`Peak Potential`)),
             hvl_num = suppressWarnings(as.numeric(HVL)))
    
    wf_vals      <- wf()
    quantity_val <- if (identical(input$kap_dose_type, "KAP")) kap_value() else dose_value()
    if (length(wf_vals) == 0 || is.null(quantity_val) || is.na(quantity_val)) return(matrix(numeric(0), nrow = 0, ncol = 0))
    
    fnums <- if (!is.null(fld_col)) suppressWarnings(as.numeric(df[[fld_col]]))[idx] else seq_along(idx)
    cols_for_interp <- c(eff_col, organ_cols)
    
    if (identical(input$spectrum_mode, "custom")) {
      kvp_target <- suppressWarnings(as.numeric(input$kvp_slider))
      hvl_target <- suppressWarnings(as.numeric(input$hvl_slider))
      if (!is.finite(kvp_target) || !is.finite(hvl_target)) return(matrix(numeric(0), nrow = 0, ncol = 0))
      
      rows <- lapply(seq_along(fnums), function(i) {
        fv <- fnums[i]
        sub_f <- df %>% filter(suppressWarnings(as.numeric(.data[[fld_col]])) == fv)
        interpolate_bilinear_field(sub_f, org_cols = cols_for_interp,
                                   kvp_target = kvp_target, hvl_target = hvl_target,
                                   kvp_col = "kvp_num", hvl_col = "hvl_num")
      })
      keep <- vapply(rows, function(x) !is.null(x) && all(is.finite(x) | is.na(x)), logical(1))
      if (!any(keep)) return(matrix(numeric(0), nrow = 0, ncol = 0))
      mat <- do.call(rbind, rows[keep]); fnums <- fnums[keep]
      colnames(mat) <- cols_for_interp
    } else {
      exact_df <- df[idx, cols_for_interp, drop = FALSE]
      mat <- suppressWarnings(as.matrix(data.frame(lapply(exact_df, as.numeric), check.names = FALSE)))
      colnames(mat) <- cols_for_interp
    }
    
    eff_vals <- mat[, 1]
    org_mat  <- if (ncol(mat) > 1) mat[, -1, drop = FALSE] else NULL
    
    m <- min(length(eff_vals), length(wf_vals))
    if (!is.null(org_mat)) m <- min(m, nrow(org_mat))
    if (m == 0) return(matrix(numeric(0), nrow = 0, ncol = 0))
    
    eff_vals <- eff_vals[seq_len(m)]
    wf_vals  <- wf_vals[seq_len(m)]
    if (!is.null(org_mat)) org_mat <- org_mat[seq_len(m), , drop = FALSE]
    
    factors <- wf_vals * quantity_val
    eff_out <- factors * eff_vals
    out <- if (!is.null(org_mat) && ncol(org_mat) > 0) {
      org_out <- sweep(org_mat, 1, factors, `*`)
      cbind(`Effective Dose` = eff_out, org_out)
    } else {
      res <- matrix(eff_out, ncol = 1); colnames(res) <- "Effective Dose"; res
    }
    
    rownames(out) <- paste0("Field_", fnums[seq_len(m)])
    out
  })
  
  # ---- Phantoms panel ----
  output$phantom_gallery_title <- renderText({
    paste(input$procedure, "|", input$sex, "|", input$age, "|", input$disease)
  })
  
  output$phantom_gallery <- renderUI({
    imgs <- list_phantom_images()
    if (length(imgs) == 0) return(tags$em(paste0("No images found in: ", phantom_dir_fs)))
    imgs <- head(imgs, 12)
    
    show_labels <- isTruthy(input$gen_field_labels) && input$gen_field_labels > 0
    edit_mode   <- identical(input$modify, "no")
    
    info <- fields_info()
    idx_rows <- split(seq_along(imgs), ceiling(seq_along(imgs) / 4))
    
    tiles <- tagList(lapply(idx_rows, function(idx_vec) {
      fluidRow(lapply(idx_vec, function(i) {
        field_num <- if (nrow(info) >= i && is.finite(info$Field[i])) info$Field[i] else i
        cf_row <- if (!is.null(rv$custom_fields) && nrow(rv$custom_fields) > 0)
          rv$custom_fields[rv$custom_fields$Field == field_num, , drop = FALSE] else NULL
        
        tpt_val <- if (!is.null(cf_row) && nrow(cf_row) == 1) cf_row$TPT else if (nrow(info) >= i) info$TPT[i] else NA_real_
        rad_val <- if (!is.null(cf_row) && nrow(cf_row) == 1) cf_row$Radiographs else if (nrow(info) >= i) info$Radiographs[i] else NA_real_
        
        under_img <- if (edit_mode) {
          tags$div(
            style = "margin-top:6px; font-size: 90%;",
            fluidRow(
              column(6,
                     numericInput(paste0("tpt_", field_num), "Field Time (s)",
                                  value = ifelse(is.finite(tpt_val), round(tpt_val, 2), NA),
                                  min = 0, step = 0.1, width = "100%")),
              column(6,
                     numericInput(paste0("rad_", field_num), "# Spot Films",
                                  value = ifelse(is.finite(rad_val), round(rad_val, 2), NA),
                                  min = 0, step = 1, width = "100%"))
            )
          )
        } else if (show_labels) {
          tags$div(
            class = "phantom-label-box",
            style = "border:1px solid #ccc; border-radius:4px; padding:6px; margin-top:6px; background:#f9f9f9; display:inline-block; text-align:left; font-size:90%;",
            tags$div(paste("Field Time (s):", ifelse(is.finite(tpt_val), round(tpt_val, 2), "NA"))),
            tags$div(paste("# Spot Films:",   ifelse(is.finite(rad_val), round(rad_val, 2), "NA")))
          )
        } else NULL
        
        column(
          width = 3,
          div(
            style = "padding:6px; text-align:center;",
            div(class = "field-title", paste("Field", field_num)),
            div(class = "phantom-img-wrap",
                tags$img(src = paste0("phantoms/", URLencode(imgs[i], reserved = TRUE)), class = "phantom-img")),
            under_img
          )
        )
      }))
    }))
    
    calc_btn <- if (edit_mode) {
      div(style = "margin-top:10px; text-align:right;",
          actionButton("apply_field_edits", "Calculate", class = "btn btn-primary"))
    } else NULL
    
    tagList(tiles, calc_btn)
  })
  
  observeEvent(input$apply_field_edits, {
    info <- fields_info()
    if (nrow(info) == 0) {
      showNotification("No fields available to edit.", type = "error"); return()
    }
    fields <- head(info$Field, 12)
    get_input_num <- function(id) suppressWarnings(as.numeric(input[[id]]))
    df_custom <- data.frame(
      Field       = fields,
      TPT         = vapply(fields, function(f) get_input_num(paste0("tpt_", f)), numeric(1)),
      Radiographs = vapply(fields, function(f) get_input_num(paste0("rad_", f)), numeric(1)),
      check.names = FALSE
    )
    rv$custom_fields  <- df_custom
    rv$custom_applied <- TRUE
    showNotification("Custom field values applied. Tables updated.", type = "message")
  })
  
  total_spot_films <- reactive({
    if (isTRUE(rv$custom_applied) && !is.null(rv$custom_fields) && nrow(rv$custom_fields) > 0) {
      v <- suppressWarnings(as.numeric(rv$custom_fields$Radiographs))
      return(sum(head(v, 12), na.rm = TRUE))
    }
    info <- fields_info()
    if (nrow(info) == 0 || !"Radiographs" %in% names(info)) return(NA_real_)
    v <- suppressWarnings(as.numeric(info$Radiographs))
    sum(head(v, 12), na.rm = TRUE)
  })
  
  output$field_summary <- renderUI({
    tot_spot <- total_spot_films()
    tot_time <- t_fluoro_total()
    spot_txt <- ifelse(is.na(tot_spot), "NA", format(round(tot_spot, 0), big.mark = ","))
    time_txt <- ifelse(is.na(tot_time), "NA", format(round(tot_time, 2), big.mark = ","))
    tags$div(
      style = "font-size: 95%; padding: 6px; background: #f7f7f7; border: 1px solid #ddd; border-radius: 4px;",
      tags$span(tags$b("Summary (all fields): ")),
      tags$span(paste0("Total spot films = ", spot_txt)),
      tags$span(" | "),
      tags$span(paste0("Total field time = ", time_txt, " s"))
    )
  })
}

# ---- Run (gadget) ----
vwr <- dialogViewer(" ", width = 3600, height = 7800)
runGadget(shinyApp(ui = ui, server = server), viewer = vwr)
# shinyApp(ui = ui, server = server)
