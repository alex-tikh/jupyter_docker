from setuptools import find_packages, setup

setup(
    name='src',
    packages=find_packages(),
    version='1.0.0',
    description='pyspark kernel',
    author='Alexander Tikhomirov',
    install_requires=[
        'marshmallow == 3.12.1',
        'marshmallow-dataclass == 8.4.1',
        'scikit-learn == 0.24.2',
        'pandas == 1.2.4',
        'numpy == 1.20.3',
        'dill == 0.3.3',
        'PyYAML == 5.4.1',
        'tsfresh==0.18.0',
        'pyspark == 3.0.2'
    ],
    license='MIT',
)
