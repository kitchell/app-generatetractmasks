[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.142-blue.svg)](https://doi.org/10.25663/brainlife.app.142)

# app-generatetractmasks
This app generate binary masks of segmented fiber tracts

### Author
- Lindsey Kitchell (kitchell@indiana.edu)
- Daniel Bullock (dnbulloc@iu.edu)

### Funding 
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)

## Running the App 

### On Brainlife.io

You can submit this App online at [https://brainlife.io/app/592dc03eb3cd7c00211dc239](https://brainlife.io/app/592dc03eb3cd7c00211dc239) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
    "t1": ../ti.nii.gz,
    "afq_fg": afq_fgclassifiedoutput
}
```
3. Execute the main.m file via matlab or the main file via singularity

### Sample Datasets

If you don't have your own input file, you can download sample datasets from Brainlife.io, or you can use [Brainlife CLI](https://github.com/brain-life/cli).


## Output

The  output of this App is a folder with the nifti images of the binary track masks. 


### Dependencies

This App require matlab or singularity to run.
