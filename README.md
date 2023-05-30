# wkhtmltopdf gem

This gem is a wrapper for standalone/static executables of the [wkhtmltopdf command line tool](https://github.com/wkhtmltopdf/wkhtmltopdf).

## How to generate standalone/static executables

The wkhtmltopdf maintainers provide packages for multiple linux distributions [here](https://github.com/wkhtmltopdf/packaging/releases).

However, to provide wkhtmltopdf executables for this gem, we need to create them as standalone/static. The following are the steps to create an amd64 executable under Ubuntu 22.04, the step to compile the static executable was based on [this post](https://github.com/wkhtmltopdf/wkhtmltopdf/issues/3468#issuecomment-324420911):

Install tools we will use for building:
```bash
sudo apt install -y python3-yaml p7zip-full docker.io python-is-python3
sudo usermod -aG docker ${USER}
```

Download the wkhtmltopdf repositories:
```bash
mkdir build_wkhtmltopdf
cd build_wkhtmltopdf
git clone --recursive https://github.com/wkhtmltopdf/wkhtmltopdf.git
git clone https://github.com/wkhtmltopdf/packaging.git
cd wkhtmltopdf
git pull
git submodule update
git checkout 0.12.6
cd /home/${USER}/build_wkhtmltopdf/packaging/
git pull
git checkout 0.12.6.1-3
```

Optional step: Edit the entry for 'buster' and change 'output: deb' to 'output: tar' to prevent downloading a second docker image and create another docker container.
```bash
vim build.yml
```

Build the dynamic executable:
```bash
./build package-docker buster-amd64 /home/${USER}/build_wkhtmltopdf/wkhtmltopdf
```

Create a docker container so we can log into it and run the step to generate the static executable:
```bash
docker run --name wkhtmltopdf_static -it -d -v/home/${USER}/build_wkhtmltopdf/wkhtmltopdf:/src -v/home/${USER}/build_wkhtmltopdf/packaging/targets/buster-amd64:/tgt -v/home/${USER}/build_wkhtmltopdf/packaging:/pkg -w/tgt/app --user 1000:1000 wkhtmltopdf/0.12:buster-amd64
docker attach wkhtmltopdf_static  # This connects you to the docker container.
# Inside the docker container:
cd src/pdf/
g++ -Wl,-O1 -o ../../bin/wkhtmltopdf outputter.o manoutputter.o htmloutputter.o textoutputter.o arghandler.o commondocparts.o commandlineparserbase.o commonarguments.o progressfeedback.o loadsettings.o logging.o multipageloader.o tempfile.o converter.o websettings.o reflect.o utilities.o pdfsettings.o pdfconverter.o outline.o tocstylesheet.o imagesettings.o imageconverter.o pdf_c_bindings.o image_c_bindings.o wkhtmltopdf.o pdfarguments.o pdfcommandlineparser.o pdfdocparts.o moc_progressfeedback.o moc_multipageloader_p.o moc_converter_p.o moc_pdfconverter_p.o moc_imageconverter_p.o moc_pdf_c_bindings_p.o moc_image_c_bindings_p.o moc_converter.o moc_multipageloader.o moc_utilities.o moc_pdfconverter.o moc_imageconverter.o qrc_wkhtmltopdf.o -static -static-libgcc -static-libstdc++    -L/tgt/qt/lib -L/tgt/qt/plugins/codecs -lqcncodecs -L/tgt/qt/lib -lqjpcodecs -lqkrcodecs -lqtwcodecs -lQtWebKit -L/usr/X11R6/lib -lQtSvg -lQtXmlPatterns -lQtGui -ljpeg -lpng -lXrender -lfontconfig -lexpat -luuid   -lfreetype -lXext -lX11 -lxcb -lXau -lXdmcp -lQtNetwork -lssl -lcrypto -lQtCore -lz -lm -ldl -lrt -lpthread
exit
```

Now back to your host machine, the static executable should be located in:
```bash
ls -l /home/${USER}/build_wkhtmltopdf/packaging/targets/buster-amd64/app/bin/wkhtmltopdf
```

## Additional notes

We are creating executable for Debian `buster` since we found a compile issue when generating the executable for Ubuntu focal, the cause of the issue is documented [here](https://github.com/wkhtmltopdf/packaging/issues/63).
And while the executable is for Debian `buster` it has been tested to work fine in Ubuntu 20.04 and 22.04.

## Other targets

To generate the static executable for other platforms, the steps are similar. These are the steps to generate an arm64/aarch64 executable:
```bash
cd /home/${USER}/build_wkhtmltopdf/packaging/
./build --use-qemu linux/amd64 package-docker buster-arm64 /home/${USER}/build_wkhtmltopdf/wkhtmltopdf
docker run --name wkhtmltopdf_static_arm64 -it -d -v/home/${USER}/build_wkhtmltopdf/wkhtmltopdf:/src -v/home/${USER}/build_wkhtmltopdf/packaging/targets/buster-arm64:/tgt -v/home/${USER}/build_wkhtmltopdf/packaging:/pkg -w/tgt/app --user 1000:1000 wkhtmltopdf/0.12:buster-arm64
docker attach wkhtmltopdf_static_arm64
# Inside the docker container:
cd src/pdf/
g++ -Wl,-O1 -o ../../bin/wkhtmltopdf outputter.o manoutputter.o htmloutputter.o textoutputter.o arghandler.o commondocparts.o commandlineparserbase.o commonarguments.o progressfeedback.o loadsettings.o logging.o multipageloader.o tempfile.o converter.o websettings.o reflect.o utilities.o pdfsettings.o pdfconverter.o outline.o tocstylesheet.o imagesettings.o imageconverter.o pdf_c_bindings.o image_c_bindings.o wkhtmltopdf.o pdfarguments.o pdfcommandlineparser.o pdfdocparts.o moc_progressfeedback.o moc_multipageloader_p.o moc_converter_p.o moc_pdfconverter_p.o moc_imageconverter_p.o moc_pdf_c_bindings_p.o moc_image_c_bindings_p.o moc_converter.o moc_multipageloader.o moc_utilities.o moc_pdfconverter.o moc_imageconverter.o qrc_wkhtmltopdf.o  -static -static-libgcc -static-libstdc++  -L/tgt/qt/lib -L/tgt/qt/plugins/codecs -lqcncodecs -L/tgt/qt/lib -lqjpcodecs -lqkrcodecs -lqtwcodecs -lQtWebKit -L/usr/X11R6/lib -lQtSvg -lQtXmlPatterns -lQtGui -ljpeg -lpng -lXrender -lfontconfig -lexpat -luuid -lfreetype -lXext -lX11 -lxcb -lXau -lXdmcp -lQtNetwork -lssl -lcrypto -lQtCore -lz -lm -ldl -lrt -lpthread
exit
# you should be back to your host machine, and the static executable should be in:
ls -l /home/${USER}/build_wkhtmltopdf/packaging/targets/buster-arm64/app/bin/wkhtmltopdf
```

