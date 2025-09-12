# Ansible Setup for Resume Website

This directory contains the Ansible playbook and related files for automating the deployment of the Lambda functions and configuration of AWS resources for the resume website project.

## Directory Structure

- **playbook.yml**: The main Ansible playbook that defines the tasks for deploying the Lambda functions and configuring AWS resources.
- **templates/**: Contains Jinja2 templates used in the playbook, such as the CloudWatch agent configuration.
  
## Requirements

- Ansible installed on your local machine.
- AWS CLI configured with your AWS credentials.

## Running the Playbook

To run the Ansible playbook, use the following command:

```bash
ansible-playbook playbook.yml -e "aws_access_key=YOUR_KEY aws_secret_key=YOUR_SECRET"
```

Replace `YOUR_KEY` and `YOUR_SECRET` with your actual AWS credentials.

## Additional Notes

- Ensure that the necessary IAM permissions are granted for the actions defined in the playbook.
- Modify the playbook and templates as needed to fit your specific requirements.