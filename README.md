# ds-template-model
This is a template repository that should be used whenever you want to create a new ML model project in GitHub.  

Below is a guide for getting started in developing new ML models that fit into the PPB target architecture.  
https://flutteruki.atlassian.net/wiki/spaces/EDS/pages/319494917/ML+model+development+guide
## Structure
 - **.github/**: This directory contains Dependabot config & standard CI/CD workflows.
 - **notebooks/**: Here, you can find Jupyter notebooks or other interactive documents related to your project.
 - **references/**: Used to store dummy data for integration tests, and any reference materials.
 - **scripts/**: Any scripts relevant to your project. **Do not change `scripts/serve`**
 - **src/**: The source code for your project can be found in this directory. Ensure you write inference code in `inference.py` to work with the default Sagemaker handler.
    - **model_code/**: Scripts used by train and inference jobs
	- **helpers/**: utility functions used in the data_quality framework
	- **utils/**: encoders and decoders scrips
	- **tests/**: UTs for each utility script
 - **studio/**: If you have any particular configs, notebooks that are designed for Sagemaker Studio, you can place them in the "studio" directory.
 - **Dockerfile**: The Dockerfile used to build your project's docker image. 
 - **poetry.lock**: In this file you can find the fixed versions of your project's current version.
 - **pyproject.toml**: File containing libraries versions and their dependencies.
## Overview
This template contains a minimum set of libraries and scripts, needed for all the projects that will be created from template

### Workflows
Below is a brief description of the workflows that exist in this template and will be replicated across all subsequent repositories.  

**1. dependabot.yml**
 - When there's available a new version of any of your project's dependencies:  
	 - Dependabot will open a new PR In order to bump the versions in .toml and .lock files  
    
**2. ci_cd_pipeline.yml**
 - on **pull_request** in **dev** branch:
	 - Install, Build and Test:
		 - Setup Python
		 - Install dependencies
		 - Run tests
 - on **push** in **main branch**:
	 - Install, Build and Test
		 - Setup Python
		 - Install dependencies
		 - Run tests
	 - Deploy:
		 - Build docker image
		 - Push to ECR
		 - Create Tag and Release (_will use the version defined in project's .toml file_)

## Usage 
### Naming conventions for new repositories
New repositories that are based on this template should follow the naming convention:
**ds-{project-name}**
### Create a new repository based on this template
Click on ***Use this template -> Create a new repository***, tick ***Include all branches*** and then ***Create repository***.
  
**Important!**  
 - After creating your repository, navigate to Settings -> Actions -> General -> (Under Actions) tick ***Accessible from repositories in the 'Flutter-Global' organization***.  

### Build a local Conda environment

#### Using a .yml file
1. Create a new .yml file, containing the following config:
	```
	name: <environment_name>

	channels:
	  - default
	  - conda-forge

	dependencies:
	  - python=3.10
	  - poetry
	```
2. Run the following commands:
	- ```conda env create -f <filename>.yml```
	- ```conda activate <environment_name>```
	- navigate to your project's root and run ```poetry install```. This will install all your project's libraries and dependencies.

#### Using the command line
1. Run the following commands:
	- ```conda create --name <environment_name> python=3.10```
	- ```conda init```
	- ```conda activate <environment_name>```
	- ```pip install poetry```
	- navigate to your project's root and run ```poetry install```. This will install all your project's libraries and dependencies.
	- ```pip install ipykernel```
	- ```python -m ipykernel install --name=<environment_name> --user```

### Add new libraries/dependencies in your project
If you need new libraries in your project, run the following commands:
- ``` poetry add <library> ``` -> this command will update your project's .toml file.
- ``` poetry lock ``` -> this command will resolve libraries dependencies and update your project's .lock file.

### Bump your project's version
When bumping your project's version, please consider the following:
 - Run ```poetry version major/minor/patch```, depending on your need.
	 - ```poetry version major``` - e.g. before: 1.3.0 -> after: 2.0.0
	 - ```poetry version minor``` - e.g. before: 2.1.4 -> after: 2.2.0
	 - ```poetry version patch``` - e.g. before: 4.1.1 -> after: 4.1.2
- Follow the guidelines below in order to decide on the versioning rule:
	- **major change** - project has new version - e.g. CAAP 1->2
	- **minor change/iteration change** - (changes in features) e.g. CAAP 3.1->3.2
	- **patch** - minor changes, bug fixes, image & libraries updates

### Notebooks
Here you can find examples of working code in notebooks.
- **replicate_image_experiments_boto.ipynb with the help of boto**
	- Get and parse all experiments searching for the best one based on the objective metric
	- Build the image
	- Push the image into ECR
	- Create an Estimator with a training job
	- Create a Batch Transform job with the help of sagemaker_utils
	and run the prediction inside of it.
- **replicate_image_experiments_sagemaker.ipynb**
	- Get and parse all experiments with the help of paginator (list_experiments)
	- Build the image
	- Prepare Hyper Parameters
	- Create the estimator with a training job
	- Initializing the predict job
	- Run the prediction job 
	- At the end you can also run a training job
- **replicate_image_jobs_boto.ipynb**
	- Get best training job with the help of paginator (list_training_jobs)
	- Create a boto session
	- Build and Push the image into ECR
	- Create an estimator and a batch transform job and run the prediction

### Useful Internal Links

[Data Science Model Architecture](https://flutteruki.atlassian.net/wiki/spaces/DS/pages/867991563/Data+Science+Model+Architecture) <br>
[Environment Creation](https://flutteruki.atlassian.net/wiki/spaces/DS/pages/867991563/Data+Science+Model+Architecture#cfm-tab-1-1)<br>
[SageMaker Custom Jobs](https://flutteruki.atlassian.net/wiki/spaces/DS/pages/867991563/Data+Science+Model+Architecture#cfm-tab-1-2)<br>
[SageMaker-Utils](https://github.com/Flutter-Global/sagemaker-utils/tree/dev)<br>
[Inference Code and Entrypoint Handling](https://github.com/Flutter-Global/ds-promo-abuse-model/pull/79)<br>

### Useful External Links

[SageMaker Python SDK](https://sagemaker.readthedocs.io/en/stable/)<br>
[SageMaker Training Toolkit](https://github.com/aws/sagemaker-training-toolkit)<br>
[SageMaker Inference Toolkit](https://github.com/aws/sagemaker-inference-toolkit)<br>
[SageMaker Pretrained Models](https://docs.aws.amazon.com/sagemaker/latest/dg/algos.html)<br>
[SageMaker Custom Models](https://aws.amazon.com/blogs/machine-learning/bring-your-own-model-with-amazon-sagemaker-script-mode/)<br>
[Script Mode](https://sagemaker-examples.readthedocs.io/en/latest/sagemaker-script-mode/index.html)<br>
[Poetry](https://python-poetry.org/docs/basic-usage/)<br>

