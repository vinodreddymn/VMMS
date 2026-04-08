pipeline {
    agent any

    environment {
        EC2_HOST = "13.234.238.152"
        EC2_USER = "ec2-user"
        APP_DIR = "/home/ec2-user/VMMS"
        FRONTEND_DIR = "/home/ec2-user/VMMS/vmms_frontend"
        NGINX_DIR = "/usr/share/nginx/html"
    }

    stages {

        stage('Clone Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-vmms',
                    url: 'https://github.com/vinodreddymn/VMMS.git'
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-vmms-key',
                        keyFileVariable: 'KEYFILE',
                        usernameVariable: 'USER'
                    )
                ]) {

                    bat '''
                    echo ===== DEPLOYMENT STARTED =====

                    echo Fixing key permissions...
                    icacls "%KEYFILE%" /inheritance:r >nul
                    icacls "%KEYFILE%" /grant:r "%USERNAME%:R" >nul

                    echo Connecting to EC2...

                    ssh -o StrictHostKeyChecking=no -i "%KEYFILE%" %USER%@%EC2_HOST% ^
                    "set -e;
                    echo ===== CONNECTED TO EC2 =====;

                    cd %APP_DIR%;
                    git pull origin main;

                    echo ===== BACKEND RESTART =====;
                    sudo systemctl restart vmms-backend;
                    sudo systemctl status vmms-backend --no-pager;

                    echo ===== FRONTEND BUILD =====;
                    cd %FRONTEND_DIR%;
                    npm install;
                    npm run build;

                    echo ===== DEPLOY FRONTEND =====;
                    sudo rm -rf %NGINX_DIR%/*;
                    sudo cp -r dist/* %NGINX_DIR%/;

                    echo ===== NGINX RESTART =====;
                    sudo systemctl restart nginx;
                    sudo systemctl status nginx --no-pager;

                    echo ===== DEPLOYMENT COMPLETED =====;"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful!'
        }
        failure {
            echo '❌ Deployment Failed!'
        }
    }
}