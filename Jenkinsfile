def label = "mypod-${UUID.randomUUID().toString()}"
// def Registry-service = dockerhub.com
// def Registry-user = paruff see ${DOCKER_HUB_USER}
 


podTemplate(label: label, containers: [
    containerTemplate(name: 'maven', image: 'maven:3.6.0-jdk-8-alpine', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'gradle', image: 'gradle:4.7.0-jdk8', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
  ],
volumes: [
    hostPathVolume(mountPath: '/root/.m2/repository', hostPath: '/root/.m2/repository'),
  hostPathVolume(mountPath: '/home/jenkins/.m2', hostPath: '/home/jenkins/.m2'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {

    node(label) {

        def RegistryRepository = "spring-conduit-api"
        def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
        
        stage('Get a Gradle project') {
            checkout scm
            container('gradle') {

                stage('Check project') {
                    sh 'gradle check'
                }
                
                stage('Test project') {
                    sh 'gradle test'
                }
                
                stage('Build project') {
                    sh 'gradle build'
                }
                
// TODO
//  sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target               
//                stage('Scan components Maven project') {
//                    sh 'mvn -B -Djavax.net.ssl.trustStore=/path/to/cacerts dependency-check:check'
//                }
            
                stage 'Code Analysis'
                    withSonarQubeEnv ("SonarQube"){
                       // sh 'gradle --info sonarqube'
                        sh './gradlew sonarqube -Dsonar.projectKey=realworld'
                    }
                
                // stage('Publish test results') {
                //     junit 'build/reports/tests/test/index.html'
                // } 
                
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
            docker build -t ${DOCKER_HUB_USER}/${RegistryRepository}:${gitCommit} .
            docker push ${DOCKER_HUB_USER}/${RegistryRepository}:${gitCommit}
            """
        }
      }
    }

    }
}
