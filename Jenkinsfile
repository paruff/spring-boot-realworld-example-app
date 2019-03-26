def label = "mypod-${UUID.randomUUID().toString()}"
podTemplate(label: label, containers: [
    containerTemplate(name: 'maven', image: 'maven:3.6.0-jdk-8-alpine', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'gradle', image: 'gradle:5.2.1-jdk8', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
  ],
volumes: [
    hostPathVolume(mountPath: '/root/.m2/repository', hostPath: '/root/.m2/repository'),
  hostPathVolume(mountPath: '/home/jenkins/.m2', hostPath: '/home/jenkins/.m2'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {

    node(label) {
        def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
        
        stage('Get a Maven project') {
            checkout scm
            container('maven') {

                stage('Validate project') {
                    sh 'mvn -B  validate'
                }
                
                stage('Compile project') {
                    sh 'mvn -B  compile'
                }
                
                stage('Unit Test and coverage project') {
                    sh 'mvn -B  test'
                }
                
// TODO
//  sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target               
//                stage('Scan components Maven project') {
//                    sh 'mvn -B -Djavax.net.ssl.trustStore=/path/to/cacerts dependency-check:check'
//                }
            
                stage 'Package and Code Analysis'
                    withSonarQubeEnv {
                        sh "mvn package sonar:sonar"
                    }
                
                stage('Publish test results') {
                    junit 'target/surefire-reports/*.xml'
                } 
                
            }
        }
        stage('Create Docker images') {
      container('docker') {
        withCredentials([[$class: 'UsernamePasswordMultiBinding',
          credentialsId: 'dockerhub',
          usernameVariable: 'DOCKER_HUB_USER',
          passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
          sh """
            docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}
            docker build -t paruff/petclinic:${gitCommit} .
            docker push paruff/petclinic:${gitCommit}
            """
        }
      }
    }

    }
}
