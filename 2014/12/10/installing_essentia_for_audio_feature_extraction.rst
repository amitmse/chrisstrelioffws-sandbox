Installing essentia for audio feature extraction
================================================

Some notes on the installation of `essentia`_, a collection of c++ code with
Python wrappers for audio feature extraction, following the `essentia
installation guide`_.

.. more::

**First**, get the code from github-- `essentia github`_.  I do this in a local
directory on my machine called :code:`~/gitlocal` so that I remember where the
github repository is located:

.. code:: bash

    $ cd ~/gitlocal
    $ git clone https://github.com/MTG/essentia.git 

This is a large amount of code, so, be patient as the code downloads and use a
good internet connection if possible.

**Second**, I make sure that all of the Ubuntu dependencies are installed using
the following command:

.. code:: bash

    $ sudo apt-get install build-essential libyaml-dev libfftw3-dev
    $ sudo apt-get install libavcodec-dev libavformat-dev python-dev
    $ sudo apt-get install libsamplerate0-dev libtag1-dev

I've divided the commands onto three lines for easier reading.

**Third**, :code:`numpy` and :code:`numpy-dev` are required for the use of
`essentia`_ from Python. I have previously installed these using :code:`pip` as
detailed elsewhere on the blog-- take a look if you need help.

**Fourth**, we *configure*: 

.. code:: bash

     $ ./waf configure --mode=release --with-python  --with-examples --with-vamp

**Note--** I removed the :code:`--with-cpptests` flag in this configure command
to avoid resulting errors.

Next, we *compile*:

.. code:: bash

    $ ./waf

**Fifth**, we install using:

.. code:: bash

    $ sudo ./waf install

**Finally**, I try importing the Python package to make sure that the install
worked:

.. code-block:: python

    Python 2.7.6 (default, Mar 22 2014, 22:59:56) 
    [GCC 4.8.2] on linux2
    Type "help", "copyright", "credits" or "license" for more information.
    >>> import essentia
    >>> print essentia.__version__
    2.1-beta2
    >>> exit()

Looks good, `essentia`_ is installed.


.. _essentia: http://essentia.upf.edu/
.. _essentia github: https://github.com/MTG/essentia
.. _essentia installation guide: http://essentia.upf.edu/documentation/installing.html

.. author:: default
.. categories:: none
.. tags:: essentia, c++, python, dsp, audio features, mir
.. comments::
