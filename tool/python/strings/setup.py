# WARNING: Please don't edit this file. It was generated by Python/WinRT

# TODO: programmaticially enable/disable debug settings (/Od and /DEBUG)

import setuptools

setuptools.setup(
    name = "%",
    version = "0.1",
    ext_modules = [ setuptools.Extension('%', 
        sources = [%],
        extra_compile_args = ["/std:c++17", "/await", "/Zi", "/Od"],
        include_dirs = ['.'],
        extra_link_args=['/DEBUG'],
        libraries = ['windowsapp']) ],
    packages = setuptools.find_packages())
