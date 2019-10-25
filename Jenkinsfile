def label = "mypod-${UUID.randomUUID().toString()}"
// def Registry-service = dockerhub.com
// def Registry-user = paruff see ${DOCKER_HUB_USER}
 


podTemplate(label: label, containers: [
    containerTemplate(name: 'maven', image: 'maven:3.6.0-jdk-8-alpine', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'gradle', image: 'gradle:4.7.0-jdk8', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.8', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:v2.13.1', command: 'cat', ttyEnabled: true)

  ],
volumes: [
    hostPathVolume(mountPath: '/root/.m2/repository', hostPath: '/root/.m2/repository'),
 // hostPathVolume(mountPath: '/home/gradle/.gradle', hostPath: '/tmp/jenkins/.gradle'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {

    node(label) {
        def RegistryRepository = "spring-conduit-api"     
        def myRepo = checkout scm
        def gitCommit = myRepo.GIT_COMMIT
        def gitBranch = myRepo.GIT_BRANCH
        def branchName = sh(script: "echo $gitBranch | cut -c8-", returnStdout: true)
        def shortGitCommit = "${gitCommit[0..10]}"
        def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
        def gitCommitCount = sh(script: "git rev-list --all --count", returnStdout: true)

        // Docker registry 
        def regURL = "registry.gitlab.com/unisys-fed/appserv-demos/real-world-app"
        def regNamespace = "paruff"

     
     // Gradle version
     def artifactID = "spring-conduit-api"
	    def artifactGroup = "org.springframework.samples"
     def AppVersion = "0.0.2"

        
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
                    withSonarQubeEnv ("sonarqube"){
                       // sh 'gradle --info sonarqube'
                        sh './gradlew sonarqube -Dsonar.projectKey=realworld'
                    }
                
           //      stage('Publish test results') {
           //          junit 'build/reports/tests/test/index.html'
           //      } 
                
            }
        }
    stage('Package and publish Docker images') {
      container('docker') {
        withCredentials([[$class: 'UsernamePasswordMultiBinding',
          credentialsId: 'dockerhub',
          usernameVariable: 'DOCKER_HUB_USER',
          passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
          sh """
            docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}
 	    docker build -t ${regNamespace}/${artifactID} .
	    docker tag ${regNamespace}/${artifactID} ${regNamespace}/${artifactID}:${AppVersion}.${shortGitCommit}
            docker tag ${regNamespace}/${artifactID} ${regNamespace}/${artifactID}:${AppVersion}.${gitCommitCount}
            docker tag ${regNamespace}/${artifactID} ${regNamespace}/${artifactID}:${AppVersion}.${BUILD_NUMBER}

	    docker push ${regNamespace}/${artifactID}
            """
        }
      }
    }

    }
}
