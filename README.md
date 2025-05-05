# ICRP Task Group 113 Pediatric Fluoroscopy

<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

> [!CAUTION]
> **Information contained in this repository is considered raw, partial and unvalidated. Material is DRAFT/DELIBERATIVE.**

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#Overview">Overview</a>
      <ul>
        <li><a href="#software-used">Software Used</a></li>
        <li><a href="#paediatric-computational-reference-phantoms">Computational Phantoms</a></li>
      </ul>
    </li>
    <li>
      <a href="#code-development-and-analysis">Code Development and Analysis</a>
      <ul>
        <li><a href="#primary-script">Primary Script</a></li>
        <li><a href="#dependencies">Dependencies</a></li>
        <li><a href="#input-files">Input Files</a></li>
        <li><a href="#output-files">Output Files</a></li>
        <li><a href="#quality-assurance-efforts">Quality Assurance Efforts</a></li>
      </ul>
    <li><a href="#contacts">Contacts</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>


<!-- ABOUT THE PROJECT -->
## Overview

The primary dosimetric data on exposures in x ray imaging procedures are measurements of entrance air kerma (for radiography), kerma-area product (for diagnostic fluoroscopy), and CTDIvol and DLP (for computed tomography). 
Such dose metrics are used to set Diagnostic Reference Levels that allow comparisons of doses received from the same procedure in different hospitals and help ensure that exposures are the minimum required to produce appropriate quality of images. 
However, effective dose is also used extensively in diagnostic x ray imaging to provide a detriment-related dose quantity to inform clinical judgements, including the comparison of different x ray procedures, and comparisons of imaging practice across different hospitals and medical facilities. 
For many years, the ICRP has produced, through its joint C2/C3 Task Group 36, reference dose coefficients for common diagnostic nuclear medicine procedures. 
However, ICRP has not provided reference dose coefficients for x ray imaging procedures and consequently different methodologies are used to convert measurements to estimates of effective dose or some surrogate of effective dose. 
These calculations rely on disparate published data based on the use of older stylized hermaphrodite phantoms that are not in alignment with the most recent ICRP reference phantoms. 
In addition, different computational methods for radiation transport have been used to report organ doses from which the effective dose is computed. 
Those responsible for such calculations and their interpretation would welcome the availability of ICRP reference organ and effective dose coefficients.

Effective dose is also used to provide a common basis for assessing the medical component of radiation exposure to populations of individual countries or world-wide. 
Currently, the United Nations Scientific Committee on the Effects of Atomic Radiation (UNSCEAR) is assembling data on medical exposures in Member States. 
Meanwhile, the US National Council on Radiation Protection and Measurement (NCRP) is updating its Report 160, which is on medical exposures to the US population. 
The availability of ICRP reference dose coefficient for diagnostic X-ray procedures as well as nuclear medicine procedures would help standardize the reporting of doses for these applications.

The proposed Task Group has three major tasks. Task A is to define reference imaging exams for the ICRP reference individuals, male and female newborn, 1-year-old, 5-year-old, 10-year-old, 15-year-old, and adult, for radiography (both DR and CR), diagnostic fluoroscopy, interventional fluoroscopy, and computed tomography. 
These reference imaging exams would not be expected to cover the full range of clinical practice and would be limited to x-ray technique factors that would be clinically consistent with imaging the body morphometry of the reference individuals. 
For example, a reference abdominal CT exam would not encompass technique factors that would be needed for optimal imaging of a very short, and very obese adult male (e.g., kVp, mA, etc.) since the reference adult male is not short nor obese. 
These reference imaging exams would be developed within the Task Group with an eye toward consistency with national and international optimized and recommended imaging protocols for each modality. 
Reference imaging exams for interventional fluoroscopy would most likely be limited to common procedures that are anatomy focused (e.g., cardiac interventional procedures), fully acknowledging that each patient intervention can be highly variable regarding imaged anatomy, combination of fluoroscopy, cine, and radiographic spot imaging, and total procedure time. 
These reference imaging exams would be fully analogous to the reference biokinetic models established by Task Group 36 on diagnostic nuclear medicine organ and effective dose coefficients, recognizing that each individual patient may metabolize the radiopharmaceutical in a manner that may substantially differ from the reference model.

Task B is to perform Monte Carlo radiation transport simulations for the reference imaging exams and to report organ absorbed dose and effective dose coefficients for each of the reference computational phantoms and for each of the relevant reference imaging exam. 
The scope of this work would be limited to the use of the reference computational phantoms of the ICRP, male and female newborn, 1-year-old, 5-year-old, 10-year-old, 15-year-old, and adult. 
In addition, the Task Group would employ the recently developed ICRP pregnant female phantom series to include all, or a subset of, the 8-member phantom series: 8-week, 10-week, 15-week, 20-week, 25-week, 30-week, 35-week, and 38-week (post-conception) phantoms.

There are increasing demands by medical professions and relevant regulatory agencies to document patient-specific exposures to diagnostic medical imaging procedures. 
As such, various software tools have been developed which are built upon extensive libraries of computational phantoms covering a wide array of body morphometries, with algorithms for matching patient to phantom. 
Other methods, such as in CT, can even use the patient’s own CT image as the basis for a patient-specific phantom for dose assessment. 
These developments are beyond the mandate of the proposed task group. 
However, a Task C is proposed to compute and compare organ doses in the 10th and 90th body height / weight percentiles for patient populations with the values obtained for the reference individuals under Task B. 
When patient-specific organ doses (single gender) are weighted by radiation and tissue weighting factors, the result is not the effective dose (which is unfortunately widely reported), and this can be clarified in the report.

This repository contains the electronic supplements of dose coefficients resulting from the pediatric fluoroscopy work stream of the Task Group 113. Additional details and history of the code development in support of this work are held in a private repository.

Members of the paediatric diagnostic fluoroscopy sub-group:
- David Borrego, US EPA
- Emily Marshall, University of Florida
- Wesley Bolch, University of Florida
- Kimberly Applegate, ICRP
- Wyatt Smither, University of Florida

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Software Used

This section lists the programs and codes used to compute these dose coefficients.

- [![PHITS][PHITS.js]][PHITS-url]
- [![MATLAB][MATLAB.js]][MATLAB-url]

### Paediatric Computational Reference Phantoms

The ICRP paediatric computational reference phantoms, as published in ICRP Publication 143, were used and can be in the supplemental materials from the hyperlink below:

- [![ICRP Paediatric Phantoms][P143.js]][P143-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Code Development and Analysis

> [!NOTE]
> The codes developed in support of this work are held in a private repository. The information included in this section is for general awareness. 
> 
> [![Static Badge](https://img.shields.io/badge/ICRP-TG113_Private_Repository-62c342?style=flat&logo=github)](https://github.com/wsmither17/ICRPTG113_ped_fluoro.git)




### Primary Script
`input_generator_phits.m`

The script that creates the necessary PHITS input files for each procedure is `input_generator_phits.m`. 
When executing the script, the user is prompted enter two required fields: 1) what the user would like to name the main output file where input files will be generated, and 2) which procedure the user would like to create input files for. 
Options for available procedures to generate PHITS input files are as follows, along with their meaning. 
Users should input the code prior to the hyphen when prompted, which correspond to the sheet name of the dependent Excel sheet discussed below:
- VCUG - voiding cystourethrogram
- VCUG_a - abnormal voiding cystourethrogram
- LGI - lower gastrointestinal series
- LGI_a - abnormal lower gastroinestinal series
- UGI - upper gastrointestinal series
- UGI_a - abnormal gastroinestinal series
- MBS - modified barium swallow
- MBS_a - abnormal modified barium swallow

### Dependencies
`procedure_outline_tags.xlsx`

This Excel sheet has the parameters for each procedure's fields that `input_generator_phits.m` pulls from, which are needed to create field margins consistent with those images in the report. 
Each fluoroscopy field is a rectangle and is delineated by four sides; each boundary is defined by an organ present within the phantoms by its unique ID tag. 
Additional parameters within `procedure_outline_tags.xlsx` are:
- Skin coverage - widen / shrink the left and right margins by this factor (plus one).
- Angle of rotation
- Whether or not to exclude the arms from the simulation
- Contrast media name (trademark)
- Contrast percentage represented as percentages in an array for each organ containing contrast
- Number of contrast locations
- Contrast locations represented as tag ID numbers in an array for each organ containing contrast - index corresponds to contrast percentage array
- Number of radiographs for a field
- Field fluoroscopy time (in seconds)
- Total procedure fluoroscopy time (in seconds)
- Disease state - normal / abnormal
- Disease

### Input Files

Input files are generated using a unique naming convention in a heirarchical folder structure. Each input file is housed within its own folder with the folder name corresponding to the PHITS input file name. An example path, for an initial main folder name of 'vcug_abnormal', and an abnormal VCUG examination would be:

`/vcug_normal/00f_VCUG_a_F2_110_62/00f_VCUG_a_F2_110_62.inp`

An explanation for each portion:
- 00f - newborn female phantom
- VCUG_a - abnormal VCUG procedure protocol
- F2 - field number two
- 110 - peak tube potentional (in kV)
- 62 - average spectrum energy (in keV)

### Output Files

Discuss how the output files were post-processed

### Quality Assurance Efforts

Discuss the QA checks with JAEA

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTACT -->
## Contacts

David Borrego - borrego.david@epa.gov

Wyatt W. Smither - wyattsmither@ufl.edu

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[PHITS.js]: https://img.shields.io/badge/PHITS-blue
[PHITS-url]: https://phits.jaea.go.jp
[MATLAB.js]: https://img.shields.io/badge/MATLAB-orange
[MATLAB-url]: https://www.mathworks.com/products/matlab.html
[P143.js]: https://img.shields.io/badge/Publication_143-red
[P143-url]: https://www.icrp.org/publication.asp?id=ICRP%20Publication%20143
[TG113Ped.js]: https://img.shields.io/badge/ICRP_TG113_Private_Repository-62c342
[TG113Ped-url]: https://github.com/wsmither17/ICRPTG113_ped_fluoro.git
