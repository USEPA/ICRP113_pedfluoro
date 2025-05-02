# ICRPTG113_ped_fluoro

<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#task-group-113-pediatric-fluoro-overview">ICRP Task Group 113 Pediatric Fluoro Overview</a>
      <ul>
        <li><a href="#codes-used">Codes Used</a></li>
        <li><a href="#paediatric-computational-reference-phantoms">Computational Phantoms</a></li>
      </ul>
    </li>
    <li>
      <a href="#input-file-generation">Input File Generation</a>
      <ul>
        <li><a href="#primary-script">Primary Script</a></li>
        <li><a href="#dependencies">Dependencies</a></li>
        <li><a href="#format-of-generated-input-files">Format of Generated Input Files</a></li>
      </ul>
    </li>
    <li>
      <a href="#output-file-processing">Output File Processing</a></li>
      <ul>
        <li><a href="#primary-script">Primary Script</a></li>
        <li><a href="#dependencies">Dependencies</a></li>
        <li><a href="#format-of-generated-input-files">Format of Generated Input Files</a></li>
      </ul>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Task Group 113 Pediatric Fluoro Overview

The primary dosimetric data on exposures in X-ray imaging procedures are measurements of entrance air kerma (for radiography), air kerma-area products (for diagnostic fluoroscopy), and CTDIvol and DLP (for computed tomography, CT). Such dose metrics are used to set Diagnostic Reference Levels that allow comparisons of doses received from the same procedure in different hospitals and help ensure that exposures are the minimum required to produce appropriate quality of images. However, effective dose is also used extensively in diagnostic x-ray imaging to provide a detriment-related dose quantity to inform clinical judgements, including the comparison of different x-ray procedures, and comparisons of imaging practice across different hospitals and medical facilities. For many years, the ICRP has produced, through its joint C2/C3 Task Group 36, reference dose coefficients for common diagnostic nuclear medicine procedures. However, ICRP has not provided reference dose coefficients for X-ray imaging procedures and consequently different methodologies are used to convert measurements to estimates of effective dose or some surrogate of effective dose. These calculations necessarily rely on disparate published data based on the use of older stylized hermaphrodite phantoms that are not in alignment with the most recent ICRP reference phantoms. In addition, different computational methods for radiation transport have been used to report organ doses from which the effective dose is computed. Those responsible for such calculations and their interpretation would welcome the availability of ICRP reference organ and effective dose coefficients.

Effective dose is also used to provide a common basis for assessing the medical component of radiation exposure to populations of individual countries or world-wide. Currently, the United Nations Scientific Committee on the Effects of Atomic Radiation (UNSCEAR) is assembling data on medical exposures in Member States. Meanwhile, the US National Council on Radiation Protection and Measurement (NCRP) is updating its Report 160, which is on medical exposures to the US population. The availability of ICRP reference dose coefficient for diagnostic X-ray procedures as well as nuclear medicine procedures would help standardize the reporting of doses for these applications.

The proposed Task Group has three major tasks. Task A is to define reference imaging exams for the ICRP reference individuals, male and female newborn, 1-year-old, 5-year-old, 10-year-old, 15-year-old, and adult, for radiography (both DR and CR), diagnostic fluoroscopy, interventional fluoroscopy, and computed tomography. These reference imaging exams would not be expected to cover the full range of clinical practice and would be limited to x-ray technique factors that would be clinically consistent with imaging the body morphometry of the reference individuals. For example, a reference abdominal CT exam would not encompass technique factors that would be needed for optimal imaging of a very short, and very obese adult male (e.g., kVp, mA, etc.) since the reference adult male is not short nor obese. These reference imaging exams would be developed within the Task Group with an eye toward consistency with national and international optimized and recommended imaging protocols for each modality. Reference imaging exams for interventional fluoroscopy would most likely be limited to common procedures that are anatomy focused (e.g., cardiac interventional procedures), fully acknowledging that each patient intervention can be highly variable regarding imaged anatomy, combination of fluoroscopy, cine, and radiographic spot imaging, and total procedure time. These reference imaging exams would be fully analogous to the reference biokinetic models established by Task Group 36 on diagnostic nuclear medicine organ and effective dose coefficients, recognizing that each individual patient may metabolize the radiopharmaceutical in a manner that may substantially differ from the reference model.

Task B is to perform Monte Carlo radiation transport simulations for the reference imaging
exams and to report organ absorbed dose and effective dose coefficients for each of the
reference computational phantoms and for each of the relevant reference imaging exam. The
scope of this work would be limited to the use of the reference computational phantoms of
the ICRP, male and female newborn, 1-year-old, 5-year-old, 10-year-old, 15-year-old, and
adult. In addition, the Task Group would employ the recently developed ICRP pregnant female
phantom series to include all, or a subset of, the 8-member phantom series: 8-week, 10
week, 15-week, 20-week, 25-week, 30-week, 35-week, and 38-week (post-conception) phantoms.

There are increasing demands by medical professions and relevant regulatory agencies to document patient-specific exposures to diagnostic medical imaging procedures. As such, various software tools have been developed which are built upon extensive libraries of computational phantoms covering a wide array of body morphometries, with algorithms for matching patient to phantom. Other methods, such as in CT, can even use the patient’s own CT image as the basis for a patient-specific phantom for dose assessment. These developments are beyond the mandate of the proposed task group. However, a Task C is proposed to compute and compare organ doses in the 10th and 90th body height / weight percentiles for patient populations with the values obtained for the reference individuals under Task B. When patient-specific organ doses (single gender) are weighted by radiation and tissue weighting factors, the result is not the effective dose (which is unfortunately widely reported), and this can be clarified in the report.

This repository contains all files utilized for the paediatric diagnostic fluoroscopy subgroup within ICRP Task Group 113.

Members of the paediatric diagnostic fluoroscopy:
- David Borrego, US EPA
- Emily Marshall, University of Florida
- Wesley Bolch, University of Florida
- Kimberly Applegate, ICRP
- Wyatt Smither, University of Florida

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Codes Used

This section lists the programs and codes used to compute these dose coefficients.

* [![PHITS][PHITS.js]][PHITS-url]
* [![MATLAB][MATLAB.js]][MATLAB-url]



### Paediatric Computational Reference Phantoms

The ICRP paediatric computational reference phantoms, as published in ICRP Publication 143, were used and can be in the supplemental materials from the hyperlink below:

* [![ICRP Paediatric Phantoms][P143.js]][P143-url]


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->

## Input File Generation

### Primary Script

_input_generator_phits.m_

The script that creates the necessary PHITS input files for each procedure is 'input_generator_phits.m'. When executing the script, the user is prompted enter two required fields: 1) what the user would like to name the main output file where input files will be generated, and 2) which procedure the user would like to create input files for. Options for available procedures to generate PHITS input files are as follows, along with their meaning. Users should input the code prior to the hyphen when prompted, which correspond to the sheet name of the dependent Excel sheet discussed below:
* VCUG - voiding cystourethrogram
* VCUG_a - abnormal voiding cystourethrogram
* LGI - lower gastrointestinal series
* LGI_a - abnormal lower gastroinestinal series
* UGI - upper gastrointestinal series
* UGI_a - abnormal gastroinestinal series
* MBS - modified barium swallow
* MBS_a - abnormal modified barium swallow

### Dependencies
_procedure_outline_tags.xlsx_

This Excel sheet has the parameters for each procedure's fields that _input_generator_phits.m_ pulls from, which are needed to create field margins consistent with those images in the report. Each fluoroscopy field is a rectangle and is delineated by four sides; each boudnary is defined by an organ present within the phantoms by its unique ID tag. Additional parameters within _procedure_outline_tags.xlsx_ are:
* skin coverage - widen / shrink the left and right margins by this factor (plus one).
* angle of rotation
* whether or not to exclude the arms from the simulation
* trademarked contrast media name
* contrast percentage represented as percentages in an array for each organ containing contrast
* number of contrast locations
* contrast locations represented as tag ID numbers in an array for each organ containing contrast - index corresponds to contrast percentage array
* Number of radiographs for a field
* Field fluoroscopy time (in seconds)
* Total procedure fluoroscopy time (in seconds)
* Disease state - normal / abnormal
* Disease


### Format of Generated Input Files

Input files are generated using a unique naming convention in a heirarchical folder structure. Each input file is housed within its own folder with the folder name corresponding to the PHITS input file name. An example path, for an initial main folder name of 'vcug_abnormal', and an abnormal VCUG examination would be:

_/vcug_normal/00f_VCUG_a_F2_110_62/00f_VCUG_a_F2_110_62.inp_

An explanation for each portion:
* 00f - newborn female phantom
* VCUG_a - abnormal VCUG procedure protocol
* F2 - field number two
* 110 - peak tube potentional (in kV)
* 62 - average spectrum energy (in keV)

## Output File Processing

Discuss how the output files were post-processed


### Quality Assurance Checks

Discuss the QA checks with JAEA


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Dose Coefficients Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the Unlicense License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Wyatt W. Smither - wyattsmither@ufl.edu

Project Link: [https://github.com/wsmither17/ICRPTG113_ped_fluoro](https://github.com/wsmither17/ICRPTG113_ped_fluoro)

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
