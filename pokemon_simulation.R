library(dplyr)
library(readxl)
library(combinat)
library(progress)
library(stringr)

types = c("NORMAL",	"FIGHTING",	"FLYING",	"POISON",	"GROUND",	"ROCK",
          "BUG",	"GHOST",	"STEEL",	"FIRE",	"WATER",	"GRASS",
          "ELECTRIC",	"PSYCHIC",	"ICE",	"DRAGON",	"DARK",	"FAIRY")

defense_type_chart = data.frame(
  NORMAL = c(1,2,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1),
  FIGHTING = c(1,1,2,1,1,0.5,0.5,1,1,1,1,1,1,2,1,1,0.5,2),
  FLYING = c(1,0.5,1,1,0,2,0.5,1,1,1,1,0.5,2,1,2,1,1,1),
  POISON = c(1,0.5,1,0.5,2,1,0.5,1,1,1,1,0.5,1,2,1,1,1,0.5),
  GROUND = c(1,1,1,0.5,1,0.5,1,1,1,1,2,2,0,1,2,1,1,1),
  ROCK = c(0.5,2,0.5,0.5,2,1,1,1,2,0.5,2,2,1,1,1,1,1,1),
  BUG = c(1,0.5,2,1,0.5,2,1,1,1,2,1,0.5,1,1,1,1,1,1),
  GHOST = c(0,0,1,0.5,1,1,0.5,2,1,1,1,1,1,1,1,1,2,1),
  STEEL = c(0.5,2,0.5,0,2,0.5,0.5,1,0.5,2,1,0.5,1,0.5,0.5,0.5,1,0.5),
  FIRE = c(1,1,1,1,2,2,0.5,1,0.5,0.5,2,0.5,1,1,0.5,1,1,0.5),
  WATER = c(1,1,1,1,1,1,1,1,0.5,0.5,0.5,2,2,1,0.5,1,1,1),
  GRASS = c(1,1,2,2,0.5,1,2,1,1,2,0.5,0.5,0.5,1,2,1,1,1),
  ELECTRIC = c(1,1,0.5,1,2,1,1,1,0.5,1,1,1,0.5,1,1,1,1,1),
  PSYCHIC = c(1,0.5,1,1,1,1,2,2,1,1,1,1,1,0.5,1,1,2,1),
  ICE = c(1,2,1,1,1,2,1,1,2,2,1,1,1,1,0.5,1,1,1),
  DRAGON = c(1,1,1,1,1,1,1,1,1,0.5,0.5,0.5,0.5,1,2,2,1,2),
  DARK = c(1,2,1,1,1,1,2,0.5,1,1,1,1,1,0,1,1,0.5,2),
  FAIRY = c(1,0.5,1,2,1,1,0.5,1,2,1,1,1,1,1,1,0,0.5,1)
)

offense_type_chart = t(defense_type_chart) %>%
  as.data.frame()
rownames(offense_type_chart) = NULL
names(offense_type_chart) = types

overall_type = tibble(
  type1 = as.vector(sapply(types, rep, 18)),
  type2 = rep(types, 18)
)
single_type_index = overall_type$type1 == overall_type$type2
overall_type$type2[single_type_index] = NA

calculate_type_combo = function(n = 3){
  battle_mat = vector()
  cat("Generating all team combinations...\n")
  type_combos = t(combn(1:dim(overall_type)[1], n))
  cat("Simulating all team combinations...\n")
  pb = progress_bar$new(total = dim(type_combos)[1])
  for(i in 1:dim(type_combos)[1]){
    combo_index = i
    type_combo = type_combos[i,]
    team_types = overall_type[type_combo,] %>%
      unlist() %>%
      na.omit()
    names(team_types) = NULL
    offense_sum = offense_type_chart[unique(team_types)]
    defense_sum = defense_type_chart[unique(team_types)]
    offense_noeffect_n = sum(unlist(offense_sum) == 0)
    offense_notveryeffective_n = sum(unlist(offense_sum) == 0.5)
    offense_effective_n = sum(unlist(offense_sum) == 1)
    offense_supereffective_n = sum(unlist(offense_sum) == 2)
    defense_noeffect_n = sum(unlist(defense_sum) == 0)
    defense_notveryeffective_n = sum(unlist(defense_sum) == 0.5)
    defense_effective_n = sum(unlist(defense_sum) == 1)
    defense_supereffective_n = sum(unlist(defense_sum) == 2)
    battle_list = tibble(combo_index,
                         offense_noeffect_n, 
                         offense_notveryeffective_n,
                         offense_effective_n,
                         offense_supereffective_n,
                         defense_noeffect_n,
                         defense_notveryeffective_n,
                         defense_effective_n,
                         defense_supereffective_n)
    battle_mat = rbind.data.frame(battle_mat, battle_list)
    pb$tick()
  }
  
  cat("Annotating all team combinations...\n")
  team_combo_list = vector()
  for(i in battle_mat$combo_index){
    specific_combo = overall_type[type_combos[i,],]
    team_combo = ""
    for(j in 1:dim(specific_combo)[1]){
      team_combo = paste(team_combo,
                         specific_combo[j,] %>%
                           unlist() %>%
                           na.omit() %>%
                           paste(collapse = "|"),
                         sep = ";")
    }
    team_combo = str_sub(team_combo,start = 2)
    team_combo_list = c(team_combo_list, team_combo)
  }
  battle_mat = battle_mat %>%
    mutate(team = team_combo_list) %>%
    select(team, everything())
  
  cat("Annotating battle summary matrix...\n")
  annotated_battle_matrix = battle_mat %>%
    mutate(offense_sum = offense_noeffect_n*0 + 
             offense_notveryeffective_n*0.5 + 
             offense_effective_n*1 + 
             offense_supereffective_n*2) %>%
    mutate(defense_sum = defense_noeffect_n*0 + 
             defense_notveryeffective_n*0.5 + 
             defense_effective_n*1 + 
             defense_supereffective_n*2) %>%
    arrange(desc(offense_sum)) %>%
    mutate(offense_ranking = 1:dim(battle_mat)[1]) %>%
    arrange(defense_sum) %>%
    mutate(defense_ranking = 1:dim(battle_mat)[1]) %>%
    mutate(overall_ranking = offense_ranking+defense_ranking) %>%
    arrange(overall_ranking) %>%
    mutate(battle_premium = offense_sum/defense_sum) %>%
    select(team, offense_sum:battle_premium)
  
  cat("Done!\n")
  return(annotated_battle_matrix)
}

team_n1 = calculate_type_combo(1)
team_n2 = calculate_type_combo(2)
team_n3 = calculate_type_combo(3)
team_n4 = calculate_type_combo(4)
team_n5 = calculate_type_combo(5)
team_n6 = calculate_type_combo(6)
