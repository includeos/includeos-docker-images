pipeline {
  agent {
    node {
      label 'worker_medium'
    }
  }

  options {
    timestamps()
  }

  parameters {
    string(name: 'INCLUDEOS_BRANCH', defaultValue: 'dev')
  }

  environment {
    IMAGE_NAME = "includeos/includeos-common:${params.INCLUDEOS_BRANCH}"
  }

  stages {
    stage('Build') {
      steps {
        script {
          // Pull latest image from docker hub
          def common = docker.image("${IMAGE_NAME}")
          common.pull()
          String HUB_ID = sh (returnStdout: true, script: "sudo docker images -q ${IMAGE_NAME}").trim()

          // Build with latest $INCLUDEOS_BRANCH
          //def localImg = docker.build("${IMAGE_NAME}",
          //                        "-f Dockerfile.common --build-arg TAG=${params.INCLUDEOS_BRANCH} .")
          sh "sudo docker build -t ${IMAGE_NAME} -f Dockerfile.common --build-arg TAG=${params.INCLUDEOS_BRANCH} ."
          String BUILT_ID = sh (returnStdout: true, script: "sudo docker images -q ${IMAGE_NAME}").trim()

          // Compare to see if anything new was built
          echo "HUB_ID: ${HUB_ID} BUILT_ID: ${BUILT_ID}"
          if ( HUB_ID == BUILT_ID ) {
            sh 'echo False > .new_content'
          } else {
            sh 'echo True > .new_content'
          }
        }
      }
    }

    stage('Upload') {
      steps {
        script {
          // Read file to see if anything new has been committed
          def content = readFile('.new_content').trim()
          echo "content: ${content} hey"
          if ( content == "True" ) {
            echo "Uploading ${IMAGE_NAME}"
            def localImg = docker.image("${IMAGE_NAME}")
            docker.withRegistry('https://registry.hub.docker.com', 'dockerhub_mnordsletten') {
              localImg.push()
            }
          } else {
              echo "The image: ${IMAGE_NAME} already exists on docker hub"
          }
        }
      }
    }
  }
}
