#!/bin/bash

YANG_RESOURCES=/var/yang
APP_DIR=/app

# Create app dir
mkdir $APP_DIR
cd $APP_DIR

# Fetch Yang Catalog project
echo "Cloning Yang Catalog project..."
git clone --depth 1 --recurse-submodules https://github.com/ietf-tools/yangcatalog.git .
mv .env-dist .env

# Create directories
echo "Creating directories..."
mkdir -p /etc/yangcatalog
mkdir -p $APP_DIR/frontend/yangcatalog-ui/tmp

mkdir -p $YANG_RESOURCES
cd $YANG_RESOURCES
directories=("all_modules" "cache/redis-json" "commit_dir" "conf" "opensearch" "ietf" "ietf-exceptions" "logs/uwsgi" "logs/opensearch" "nginx" "nonietf/openconfig" "nonietf/yangmodels" "redis" "tmp" "ytrees")
for directory in ${directories[@]}; do
    mkdir -p $directory -m 755
done

cd $YANG_RESOURCES/nginx
nginx_directories=("compatibility" "drafts" "private" "results" "stats" "YANG-modules")
for directory in ${nginx_directories[@]}; do
    mkdir -p $directory -m 755
done

# Clone the directories that contain the YANG models
echo "Cloning YANG models..."
cd $YANG_RESOURCES/nonietf/openconfig
git clone --recurse-submodules https://github.com/openconfig/public.git
cd $YANG_RESOURCES/nonietf/yangmodels
git clone --recurse-submodules https://github.com/YangModels/yang.git

# yang-catalog@2018-04-03 module needs to be indexed to OpenSearch
echo "Creating data/conf files..."
cd $YANG_RESOURCES
echo "{\"yang-catalog@2018-04-03/ietf\": \"/var/yang/all_modules/yang-catalog@2018-04-03.yang\"}" > yang2_repo_cache.dat

# Add iana-if-types revisions in exception file
cd $YANG_RESOURCES/ietf-exceptions
echo "iana-if-type@2022-03-07.yang\niana-if-type@2022-08-17.yang\niana-if-type@2022-08-24.yang" > iana-exceptions.dat

# Make sure module yang-catalog@2018-04-03 is available
cd $YANG_RESOURCES/all_modules
curl -X GET https://raw.githubusercontent.com/YangModels/yang/main/experimental/ietf-extracted-YANG-modules/yang-catalog%402018-04-03.yang -o yang-catalog@2018-04-03.yang

# Store file to the cache/redis-json to be able to load it at the start of yc-api-recovery
cd $APP_DIR
cp setup/yang-catalog.json $YANG_RESOURCES/cache/redis-json/$(date +"%Y-%m-%d_00:00:00-UTC.json")
cp conf/redis_databases.json $YANG_RESOURCES/redis/redis_databases.json
cp conf/yangcatalog.conf.sample $YANG_RESOURCES/conf/yangcatalog.conf

# Pull RFCs and Draft files needed for module-compilation
echo "Pulling RFC and I-D files... (this might take some time)"
cd $YANG_RESOURCES/ietf
rsync -avz --include 'draft-*.txt' --include 'draft-*.xml' --exclude '*' --delete rsync.ietf.org::internet-drafts my-id-mirror
rsync -avlz --delete --include="rfc[0-9]*.txt" --exclude="*" ftp.rfc-editor.org::rfcs rfc

# Add yang user -> whole $YANG_RESOURCES tree structure needs to belong to user 'yang'
echo "Creating yang user/group..."
groupadd -g 1001 -r yang
useradd -r -g yang -u 1016 yang
chmod 755 $YANG_RESOURCES
chown -R yang:yang $YANG_RESOURCES

# Copy files
echo "Putting installer files into place..."
cd $APP_DIR
cp /var/yang/confd-8.0.linux.x86_64.installer.bin ./resources/confd-8.0.linux.x86_64.installer.bin
chmod +x ./resources/confd-8.0.linux.x86_64.installer.bin

cp /var/yang/yumapro-client-21.10-12.deb11.amd64.deb ./resources/yumapro-client-21.10-12.deb11.amd64.deb

cp /var/yang/pt-topology-0.1.0.tgz ./frontend/yangcatalog-ui/tmp/pt-topology-0.1.0.tgz

# Set boot init script
echo "Setting yang init script..."
cp /app/packer/files/init.sh /app/init.sh
chmod +x /app/init.sh
cp /app/packer/files/yang-boot.service /etc/systemd/system/yang-boot.service
systemctl daemon-reload
systemctl start yang-boot.service
systemctl enable yang-boot.service

# Docker Build
docker compose build
