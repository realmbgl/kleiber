#!/usr/bin/env python
"""kleiber project"""
from setuptools import find_packages, setup

REQUIRES = [
    'docopt',
    'softlayer',
    'softlayer-object-storage',
    'pyyaml',
    'jinja2'
]

setup(name='kleiber',
      version='0.1',
      description='kleiber softlayer orchestrator',
      long_description='test',
      platforms=["Linux"],
      author="IBM SoftLayer",
      author_email="softlayer@softlayer.com",
      url="http://sldn.softlayer.com",
      license="MIT",
      packages=find_packages(),
      entry_points={
        'console_scripts': [
            'kleiber=kleiber:main',
        ],
      },
      install_requires=REQUIRES,
      zip_safe=False,
      include_package_data=True,
      )
