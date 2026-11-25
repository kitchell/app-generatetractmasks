[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.142-blue.svg)](https://doi.org/10.25663/brainlife.app.142)

# app-generatetractmasks

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Generates one binary NIfTI volume mask per segmented white matter tract from a tract classification and tractogram, using a compiled MATLAB script with vistasoft.**

Rebuilds each tract from the white matter classification and whole-brain tractogram, maps its streamline nodes into the T1 image grid at a chosen voxel size, counts streamline visits per voxel and binarizes the result either by Gaussian smoothing and a 20th-percentile cut or by a fixed streamline-count threshold. Use it to obtain tract volume masks for ROI-based or shape analyses. The T1 must be ACPC-aligned and in the same space as the tractogram.

| | |
|---|---|
| 📥 **Inputs** | `neuro/anat/t1w` · `neuro/wmc` · `neuro/track/tck` |
| 📤 **Outputs** | `neuro/tractmasks` |
| 🐳 **Container** | `brainlife/mcr:neurodebian1604-r2017a` |
| ⚙️ **Resources** | 8 CPUs · 0.58 h walltime |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.142](https://doi.org/10.25663/brainlife.app.142) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `T1` | `neuro/anat/t1w` (acpc_aligned) | yes | ACPC-aligned T1-weighted image used as the reference grid for the masks. Must be in the same space as the tractogram. |
| `wmc` | `neuro/wmc` | yes | White matter classification (classification.mat) assigning streamlines of the tractogram to named tracts. |
| `wbfg` | `neuro/track/tck` | yes | Whole-brain .tck tractogram that the classification indexes. |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `output` | `neuro/tractmasks` | A masks directory with one binary <tract>_Vol.nii.gz mask per non-empty tract and a color.json of tract colours. |

<details>
<summary><b>⚙️ Parameters</b> (3)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `threshold` | number | `2` | Streamline-count threshold per voxel used to binarize the mask when smooth is false. |
| `smooth` | boolean | `true` | If true, smooth the streamline-count volume with a 3x3x3 Gaussian and keep voxels above the 20th percentile of non-zero values instead of using threshold. |
| `voxelResize` | number | `0.7` | Isotropic voxel size of the output masks (the T1 grid is resampled to this size). |

</details>

📚 **References used by this App:**
- Kitchell L. Shape Analysis of Human White Matter Tracts: An Examination of Normal Morphological Variability and the Association Between Morphology, Brain Size, and Behavior. Indiana University (2020).

<!-- brainlife-app:end -->

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
