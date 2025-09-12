# Comprehensive Resume Website with Advanced AWS Features

This project is a comprehensive solution for creating a static resume website with dynamic elements. It utilizes various AWS services to enhance functionality and provide a seamless user experience.

## Features

- **Static Resume Website**: Hosted on AWS S3 and served via CloudFront for fast content delivery.
- **Visitor Counter**: Tracks the number of visitors using AWS Lambda and DynamoDB.
- **Contact Form**: Allows users to send messages via a contact form, utilizing AWS SES for email delivery.
- **Analytics**: Monitors website performance and usage through AWS CloudWatch.
- **Infrastructure as Code**: Managed using Terraform for easy setup and deployment.
- **Configuration Management**: Automated deployment processes with Ansible.
- **CI/CD Pipeline**: Integrated with AWS CodePipeline for continuous integration and deployment from GitHub.

## Project Structure

```
resume-website-s3/
├── ansible/
│   ├── playbook.yml
│   ├── README.md
│   └── templates/
│       └── cloudwatch-config.json.j2
├── frontend/
│   ├── index.html
│   └── README.md
├── lambda/
│   ├── README.md
│   ├── contact-form/
│   │   └── index.js
│   └── visitor-counter/
│       └── index.js
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md
│   └── variables.tf
└── README.md
```

## Setup Instructions

1. **Clone the Repository**: 
   Clone this repository to your local machine.

2. **Configure AWS Credentials**: 
   Ensure you have your AWS credentials set up in `~/.aws/credentials`.

3. **Deploy Infrastructure**:
   - Navigate to the `terraform` directory.
   - Run `terraform init` to initialize the Terraform configuration.
   - Run `terraform apply` to create the necessary AWS resources.

4. **Deploy Lambda Functions**:
   - Navigate to the `ansible` directory.
   - Run the Ansible playbook with the command:
     ```
     ansible-playbook playbook.yml -e "aws_access_key=YOUR_KEY aws_secret_key=YOUR_SECRET"
     ```

5. **Upload Frontend**:
   - Upload the `index.html` and other assets to the S3 bucket created by Terraform, or let CodePipeline handle it automatically after pushing to GitHub.

6. **Access the Website**:
   - Once deployed, access your resume website via the CloudFront distribution URL provided in the Terraform output.

## Monitoring and Maintenance

- Use AWS CloudWatch to monitor the performance and health of your resources.
- Regularly check the SES dashboard for email delivery metrics.
- Monitor DynamoDB for visitor count and adjust read/write capacity as needed.

This project provides a robust and scalable solution for hosting a professional resume website with dynamic features.



ToDo
Update git cred
Iam policies need updating
Cloudfront integration, with s3.