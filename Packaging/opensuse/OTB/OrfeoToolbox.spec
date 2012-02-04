#
# spec file for package OrfeoToolbox
#

# norootforbuild

Name:           OrfeoToolbox
Version:        3.12.0
Release:        1
Summary:        The Orfeo Toolbox is a C++ library for remote sensing image processing
Group:          Development/Libraries
License:        Cecill
URL:            http://www.orfeo-toolbox.org
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
# BuildArch:      noarch

BuildRequires:	cmake >= 2.8.0
BuildRequires:  libgdal-devel libgeotiff-devel gcc-c++ gcc gettext-runtime gettext-tools freeglut-devel libpng-devel uuid-devel libproj-devel libexpat-devel libicu-devel libtool libltdl7 swig python-devel python python-base
Requires:       gdal fltk expat libgdal1 libgeotiff freeglut libpng python
BuildRequires:  fdupes libOpenThreads-devel boost-devel
BuildRequires:	fltk curl libqt4-devel
BuildRequires:	fltk-devel

%description
The %{name} is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program

%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name} = %{version}
Requires: 	cmake gcc-c++ gcc freeglut-devel libgeotiff-devel libgdal-devel freeglut libpng14-devel boost-devel fltk-devel fltk

%description    devel
Development files for the %{name} library. The %{name} is a library of image processing algorithms developed by CNES in the frame of the ORFEO Accompaniment Program


%prep
%setup -q


%build
cd ..
mkdir temp
cd temp
cmake  -DBUILD_EXAMPLES:BOOL=OFF \
       -DBUILD_TESTING:BOOL=OFF \
       -DBUILD_SHARED_LIBS:BOOL=ON \
       -DBUILD_APPLICATIONS:BOOL=ON \
       -DOTB_USE_GETTEXT:BOOL=OFF \
       -DOTB_USE_CURL:BOOL=ON \
       -DOTB_USE_MAPNIK:BOOL=OFF \
       -DOTB_USE_EXTERNAL_EXPAT:BOOL=ON \
       -DOTB_USE_EXTERNAL_FLTK:BOOL=ON \
       -DOTB_USE_EXTERNAL_BOOST:BOOL=ON \
       -DOTB_USE_EXTERNAL_GDAL:BOOL=ON \
       -DOTB_WRAP_QT:BOOL=ON \
       -DOTB_WRAP_PYTHON:BOOL=OFF \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr \
       -DCMAKE_SKIP_RPATH:BOOL=ON \
       -DOTB_INSTALL_LIB_DIR:STRING=/%{_lib}/otb \
       -DITK_INSTALL_LIB_DIR:STRING=/%{_lib} \
       -DOTB_INSTALL_APP_DIR:STRING=/%{_lib}/otb/applications \
       -DCMAKE_BUILD_TYPE:STRING="Release" ../%{name}-%{version}/

make VERBOSE=1 %{?_smp_mflags}


%install
cd ../temp
make install DESTDIR=%{buildroot}
#mv %{buildroot}/usr/lib/otb/*.cmake %{buildroot}%{_libdir}/otb/
%if "%{_lib}" == "lib64"
#mkdir %{buildroot}/usr/%{_lib}
mv %{buildroot}/usr/lib/otb/* %{buildroot}/usr/%{_lib}/otb/
%endif
%fdupes %{buildroot}%{_includedir}/otb


%clean
rm -rf %{buildroot}

%post
LDCONFIG_FILE=/etc/ld.so.conf.d/otb.conf
%if "%{_lib}" == "lib64"
if [ ! -f "$LDCONFIG_FILE" ] ; then
	cat > "$LDCONFIG_FILE" <<EOF
# Orfeo Toolbox related search paths
/usr/lib64/otb
/usr/lib64/otb/applications
/usr/lib64/otb/python
EOF
fi
%else
if [ ! -f "$LDCONFIG_FILE" ] ; then
        cat > "$LDCONFIG_FILE" <<EOF
# Orfeo Toolbox related search paths
/usr/lib/otb
/usr/lib/otb/applications
/usr/lib/otb/python
EOF
fi
%endif
/sbin/ldconfig

%postun
LDCONFIG_FILE=/etc/ld.so.conf.d/otb.conf
if [ -f "$LDCONFIG_FILE" ] ; then
	rm -f "$LDCONFIG_FILE"
fi
/sbin/ldconfig

%files
%defattr(-,root,root,-)
%{_bindir}/*
%{_libdir}/lib*.so.*
#%{_libdir}/otb/
%{_libdir}/otb/lib*.so.*
%{_libdir}/otb/applications/
#%{_libdir}/otb/applications/*
#%{_libdir}/otb/python/*

%files devel
%defattr(-,root,root,-)
%{_includedir}/otb
%{_includedir}/otb/*
%{_libdir}/otb
%{_libdir}/otb/lib*.so
%{_libdir}/lib*.so
%{_libdir}/otb/*.cmake 

%changelog
