# Run PSA for OCIS
# This module allows users to run deterministic and PSA for optimal combination implementation strategy at documented scale
# PREREQUISITE: run documented and determine the production function first

#############################################################################
# 1. SET directpry and workspace
#############################################################################
rm(list=ls())
library(rstudioapi)
library(LEMHIVpack)
#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

source("01_setup/CascadeCEA-Interventions-1-LoadBaselineWorkspace.R")

# SELECT city ##
CITY <- select.list(all.cities, multiple = FALSE,
                        title = 'Select city', graphics = FALSE)
# ww <- 1; CITY <- all.cities[[ww]] # Otherwise you can set city by its index

## LOAD list of all combinations, interventions indexed by number in each combination
# if the list does not exist, source("CascadeCEA-Combination-0-Setup-combination.list.R")
combination.list <- readRDS("Combination/Combination.list.rds")

## LOAD ODE function
#source("R/01_setup/CascadeCEA-Model-0-Function-ode_model-Combination.R")

## LOAD analysis scenario
case = "SA"  # DM for deterministic, SA for sensitivity analysis
param.sets <- 2000

## LOAD all input parameters and comparators
source("01_setup/CascadeCEA-Interventions-1-LoadParameterWorkspace-Combination.R")

## Executing PSA analyses

for (nn in 1:(length(interventions)-1)){
  current.int = interventions[nn]
  outcome.int.SA.mx <- matrix(0, nrow = param.sets, ncol = 44)

  for (cc in 1:param.sets){
    print(paste0("Running PSA for parameter set: ", cc))

    ##Load input data
    input.parameters = all.params.list[[cc]]
    All.Costs.ls     = All.Costs.ls.list[[cc]]
    StateQALYs       = State.QALYs.ls.list[[cc]]
    Int.Baseline.ls  = Int.Baseline.ls.list[[cc]]
    Int.Eff.ls       = Int.Eff.ls.list[[cc]]

    outcome.int.SA.mx[cc, ] = comb.eva.func(input.parameters = input.parameters, current.int = current.int)
  }

  colnames(outcome.int.SA.mx)        <- rep("FILL", 44)
  colnames(outcome.int.SA.mx)[1:6]   <- c("Infections.total-20Y", "SuscPY-over20Y", "Infections.total-10Y", "SuscPY-over10Y", "Infections.total-5Y", "SuscPY-over5Y")
  colnames(outcome.int.SA.mx)[7:32]  <- paste0("Year", c(2015:2040))
  colnames(outcome.int.SA.mx)[33:44] <- c("QALYs.sum", "costs.total.sum", "costs.hru.sum", "costs.art.sum", "costs.art.ini.sum",
                                           "costs.oat.sum", "costs.prep.sum", "costs.prep.tests.sum", "costs.test.sum", "int.costs.sum",
                                           "int.impl.costs.sum", "int.sust.costs.sum")

  saveRDS(outcome.int.SA.mx,   paste0("SingleIntervention/Outcome-", current.int, "-", CITY, "-PSA.rds"))
}

