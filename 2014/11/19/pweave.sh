#! /bin/sh
#
# pweave.sh
# Copyright (C) 2014 Christopher C. Strelioff <chris.strelioff@gmail.com>
#
# Distributed under terms of the MIT license.
#
Pweave -f sphinx --figure-directory figs inferring_probabilities_with_a_beta_prior_a_third_example_of_bayesian_calculations.Pnw 
Ptangle inferring_probabilities_with_a_beta_prior_a_third_example_of_bayesian_calculations.Pnw
