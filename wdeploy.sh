start=$(date +%s)

SSH_KEY_PATH="~/dev/ssh/crisis3"
SERVER="crisislogger@34.68.123.247"
DEST_FOLDER="/home/admin/web/front.crisislogger.care/public_html"
USER="crisislogger"

PARAMS="USER=\"$USER\" DEST_FOLDER=\"$DEST_FOLDER\""

echo ===================================================
echo Autodeploy server
echo ===================================================
echo build
yarn run build
echo build finished
echo ===================================================
echo compress build files
mv build buildnew
tar -czf build.tar.gz buildnew
rm -rf buildnew
echo compress build files finished
echo ===================================================
echo upload build files
# scp -i $SSH_KEY_PATH build.tar.gz $SERVER:$DEST_FOLDER
rsync -Pav -e "ssh -i $SSH_KEY_PATH" build.tar.gz $SERVER:$DEST_FOLDER
rm -f build.tar.gz
echo upload build files finished
echo ===================================================
echo Connecting to remote server...
ssh -i $SSH_KEY_PATH $SERVER $PARAMS 'bash -i' <<-'ENDSSH'
    #Connected

#    su $USER

    cd $DEST_FOLDER

    rm -rf buildnew/
    tar -xzf  build.tar.gz

    if [ -d build ]; then
       mv build buildold
    fi
    mv buildnew/ build
    rm -rf buildold/
    rm -f build.tar.gz

    sudo chown -R $USER:$USER $(pwd)
    sudo find $(pwd) -type d -exec chmod 775 {} \;
    sudo find $(pwd) -type f -exec chmod 664 {} \;

    exit
ENDSSH

end=$(date +%s)

runtime=$((end - start))
echo deploy took $runtime seconds
