# ANON


## BUILD INSTRUCTIONS

        - Install Flutter
        - Connect device & enable USB Debugging
        - Clone ANON repo: 

                git clone https://gitea.com/anonero/anon.git &&
                cd /anon/android/external-libs

        - Clone Monero repo:
         
                git clone https://gitea.com/anonero/monero.git &&
                cd monero &&
                git checkout release-v0.18.1.0-monerujo &&
                git submodule update --init --force &&
                cd ../ &&
                make &&
                cd ../../

        - Install & run APK: `flutter run --profile`