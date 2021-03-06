.. _bayes medical tests with python:

Revisiting the medical tests example with Python and Lea
========================================================

In this post I will use Python, and the probabilistic programming package
`Lea`_, to re-analyze an example of Bayes' Theorem covered in an earlier post:
:ref:`bayes medical tests`.  The focus will be on translating the by-hand
calculations into Python code.  If you are unfamiliar with the example, it
would be helpful to read the previous post before continuing. Assuming you are
set, let's get started!

.. more::

First, let's restate the problem::

    1% of women at age forty who participate in routine
    screening have breast cancer.  80% of women with
    breast cancer will get positive mammographies. 9.6%
    of women without breast cancer will also get positive
    mammographies. A woman in this age group had a positive
    mammography in a routine screening.  What is the
    probability that she actually has breast cancer?

This is an interesting and important problem to think about because many people
get this wrong. Often people assume that a positive mammogram means
that breast cancer is certain, or at least very likely.  Given the
probabilities stated above, that assumption is incorrect-- let's revisit this
important problem.

I'll be using `Lea`_, a package for probabilistic programming, to answer this
question and provide some context.  See my post :ref:`prob prog lea 1` for
installation instructions and a first example of using the `Lea`_ package. Our
first step is to import `Lea`_ and some convenience functions:


.. code-block:: python

    from __future__ import division, print_function
    from lea import Lea
    



Some notes:

* This post is using `Lea`_ version 2.1.1, the current version at this time

* A gist, containing all  of the code is available
  `here <https://gist.github.com/cstrelioff/d0d424510c6d467173d4>`_

Next, following the by-hand post :ref:`bayes medical tests`, we define the
probability of cancer for women at age 40 (this can be considered the *prior*
in this problem-- the probability of cancer before data from the mammogram
is available):


.. code-block:: python

    # define cancer dist
    cancer = Lea.fromValFreqs(('yes', 1),
                              ('no',  99))
    
    print('\nCancer Distribution',
          'P(C)',
          cancer.asPct(),
          sep='\n')
    

::

    
    Cancer Distribution
    P(C)
     no :  99.0 %
    yes :   1.0 %
    
    



This corresponds to :math:`P(C=\textrm{yes}) = 0.01` and
:math:`P(C=\textrm{no}) = 0.99` in the previous post.  These values reflect
the probability of cancer in this age group after extensive investigation to be
sure that cancer is present.

Next, we have to define *two distributions* that describe the ability of
the mammogram to detect cancer accurately:

* First, one for **women known to have cancer**:


.. code-block:: python

    # prob for mamm given cancer == yes
    mamm_g_cancer = Lea.fromValFreqs(('pos', 80),
                                     ('neg', 20))
    
    print('\nProb for mammogram given cancer',
          'P(M|C=yes)',
          mamm_g_cancer.asPct(),
          sep='\n')
    

::

    
    Prob for mammogram given cancer
    P(M|C=yes)
    neg :  20.0 %
    pos :  80.0 %
    
    



These probabilities correspond to
:math:`P(M=\textrm{pos} \vert C=\textrm{yes}) = 0.80` and
:math:`P(M=\textrm{neg} \vert C=\textrm{yes}) = 0.20` in the previous post. So,
if a woman *has cancer for sure* the mammogram will be positive 80% of the
time-- these are **true positives**.

* Next, one for **women known to be cancer free**:


.. code-block:: python

    # prob for mamm given cancer == no
    mamm_g_no_cancer = Lea.fromValFreqs(('pos', 96),
                                        ('neg', 1000-96))
    
    print('\nProb for mammogram given NO cancer',
          'P(M|C=no)',
          mamm_g_no_cancer.asPct(),
          sep='\n')
    

::

    
    Prob for mammogram given NO cancer
    P(M|C=no)
    neg :  90.4 %
    pos :   9.6 %
    
    


These probabilities correspond to 
:math:`P(M=\textrm{pos} \vert C=\textrm{no}) = 0.096` and
:math:`P(M=\textrm{neg} \vert C=\textrm{no}) = 0.904`.  So, if a woman *does
not have cancer* the probability of a positive mammogram is 9.6%--of course,
these are **false positives**.

Finally, at least for the setup, we need to connect the probabilities of cancer
and the mammogram using `Lea`_.  To do this we use a conditional probability
table:


.. code-block:: python

    # conditional probability table
    mammograms = Lea.buildCPT((cancer == 'yes', mamm_g_cancer),
                              (cancer == 'no', mamm_g_no_cancer))
    
    print('\nMammograms',
          'P(M)',
          mammograms.asPct(),
          sep='\n')
    

::

    
    Mammograms
    P(M)
    neg :  89.7 %
    pos :  10.3 %
    
    



The values are the marginal probabilities for the mammogram results:
:math:`P(M=\textrm{pos}) = 0.103` and :math:`P(M=\textrm{neg}) = 0.897`.
This says that the probability of a positive mammogram is about 10%! However,
we have to keep in mind that this includes **both** true positives and
false positives.

`Lea`_ will let us look at the *joint probabilities* and separate out these
effects as follows:


.. code-block:: python

    # get joint probs for all events
    joint_probs = Lea.cprod(mammograms, cancer)
    
    print('\nJoint Probabilities',
          'P(M, C)',
          joint_probs.asPct(),
          sep='\n')
    

::

    
    Joint Probabilities
    P(M, C)
     ('neg', 'no') :  89.5 %
    ('neg', 'yes') :   0.2 %
     ('pos', 'no') :   9.5 %
    ('pos', 'yes') :   0.8 %
    
    



From this result we can see that the 10.3% positive mammograms is split into
9.5% *false positives* and 0.8% *true positives*! So, why do we use mammograms?
Well, they do provide information-- but, not certainty-- about the presence of
cancer.

We can calculate the conditional probability that the original question asks
for using `Lea`_: what is probability of cancer **given** a positive
mammogram?


.. code-block:: python

    # prob cancer GIVEN mammogram==pos
    print('\nThe Answer',
          'P(C|M=pos)',
          cancer.given(mammograms == 'pos').asPct(),
          sep='\n')
    

::

    
    The Answer
    P(C|M=pos)
     no :  92.2 %
    yes :   7.8 %
    
    



As we can see, this calculation provides both
:math:`P(C=\textrm{yes} \vert M=\textrm{pos})` and
:math:`P(C=\textrm{yes} \vert M=\textrm{pos})`.
The code does not make it clear
that Bayes' Theorem is being used in the calculation, but that's what is done
to get the desired conditional probability-- see the previous post and the
by-hand calculations to see how this works.

From the result we can see that the probability of cancer given a positive
mammogram is about 8%, that is
:math:`P(C=\textrm{yes} \vert M=\textrm{pos})=0.078`.
This should be compare with the probability of 1%,
:math:`P(C=\textrm{yes})=0.01`, without the information from a mammogram,
**an eight-fold increase that might
lead to further investigation**.  However, a positive mammogram *does not* mean
that breast cancer is likely; only more probable. Of course, the downside of
all this is that many women with *no cancer* will get positive mammograms
leading to further (unneeded tests).

Note, a negative mammogram also provides information:


.. code-block:: python

    # prob cancer GIVEN mammogram==neg
    print('\nExtra Info',
          'P(C|M=neg)',
          cancer.given(mammograms == 'neg').asPct(),
          sep='\n')
    

::

    
    Extra Info
    P(C|M=neg)
     no :  99.8 %
    yes :   0.2 %
    
    



This deceases the probability of cancer from 1% before the mammogram to 0.2%
after the negative mammogram.-- again, this is not certain or absolute, just
the probabilities have changed.

So, that's it. A re-analysis of the medical test example using Python and
`Lea`_  Be sure to check out the package for more information and examples. As
always, comments and questions are very welcome.


.. _Lea: https://code.google.com/p/lea/
.. _Lea Python tutorials: https://code.google.com/p/lea/wiki/LeaPyTutorial

.. author:: default
.. categories:: none
.. tags:: python, Lea, joint probability, conditional probability, marginal probability, Bayesian
.. comments::
