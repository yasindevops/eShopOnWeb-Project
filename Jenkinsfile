pipeline {
    agent any

    stages {
        stage('Başlangıç') {
            steps {
                echo 'Harika! Jenkinsfile bulundu ve çalışıyor.'
                echo 'Kodlar Gitea sunucusundan başarıyla çekildi.'
            }
        }
        stage('Kontrol') {
            steps {
                // Burada dosyaların gelip gelmediğini kontrol ediyoruz
                sh 'ls -la' 
            }
        }
    }
}