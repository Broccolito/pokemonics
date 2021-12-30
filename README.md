# Pokemon Simulator
When a computational biologist has tried hard enough on his job, he shouldn't be coming back home, wondering which Pokemons to use to battle the elite four.



#### Directory Tree

```bash
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        12/30/2021  12:14 AM                img                      ## Images
-a----        12/29/2021   9:07 PM          61639 all_pokemons_stats.xlsx  ## Base Stats
-a----        12/30/2021  12:16 AM             92 auto_push.bat
-a----        12/30/2021  12:11 AM           1087 LICENSE                  ## MIT 
-a----        12/30/2021  12:03 AM           4135 pokemon_simulation.R 
-a----        12/30/2021  12:11 AM            172 README.md
```



#### Simulating the best team type combination

Loading libraries needed:

```R
library(dplyr)
library(readxl)
library(combinat)
library(progress)
```



Loading all the Pokemon types:

```R
types = c("NORMAL",	"FIGHTING",	"FLYING",	"POISON",	"GROUND",	"ROCK",
          "BUG",	"GHOST",	"STEEL",	"FIRE",	"WATER",	"GRASS",
          "ELECTRIC",	"PSYCHIC",	"ICE",	"DRAGON",	"DARK",	"FAIRY")
```



Loading type chart:

```R
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
```



Defensive type chart

| NORMAL | FIGHTING | FLYING | POISON | GROUND | ROCK |  BUG | GHOST | STEEL | FIRE | WATER | GRASS | ELECTRIC | PSYCHIC |  ICE | DRAGON | DARK | FAIRY |
| -----: | -------: | -----: | -----: | -----: | ---: | ---: | ----: | ----: | ---: | ----: | ----: | -------: | ------: | ---: | -----: | ---: | ----: |
|      1 |      1.0 |    1.0 |    1.0 |    1.0 |  0.5 |  1.0 |   0.0 |   0.5 |  1.0 |   1.0 |   1.0 |      1.0 |     1.0 |  1.0 |    1.0 |  1.0 |   1.0 |
|      2 |      1.0 |    0.5 |    0.5 |    1.0 |  2.0 |  0.5 |   0.0 |   2.0 |  1.0 |   1.0 |   1.0 |      1.0 |     0.5 |  2.0 |    1.0 |  2.0 |   0.5 |
|      1 |      2.0 |    1.0 |    1.0 |    1.0 |  0.5 |  2.0 |   1.0 |   0.5 |  1.0 |   1.0 |   2.0 |      0.5 |     1.0 |  1.0 |    1.0 |  1.0 |   1.0 |
|      1 |      1.0 |    1.0 |    0.5 |    0.5 |  0.5 |  1.0 |   0.5 |   0.0 |  1.0 |   1.0 |   2.0 |      1.0 |     1.0 |  1.0 |    1.0 |  1.0 |   2.0 |
|      1 |      1.0 |    0.0 |    2.0 |    1.0 |  2.0 |  0.5 |   1.0 |   2.0 |  2.0 |   1.0 |   0.5 |      2.0 |     1.0 |  1.0 |    1.0 |  1.0 |   1.0 |
|      1 |      0.5 |    2.0 |    1.0 |    0.5 |  1.0 |  2.0 |   1.0 |   0.5 |  2.0 |   1.0 |   1.0 |      1.0 |     1.0 |  2.0 |    1.0 |  1.0 |   1.0 |
|      1 |      0.5 |    0.5 |    0.5 |    1.0 |  1.0 |  1.0 |   0.5 |   0.5 |  0.5 |   1.0 |   2.0 |      1.0 |     2.0 |  1.0 |    1.0 |  2.0 |   0.5 |
|      0 |      1.0 |    1.0 |    1.0 |    1.0 |  1.0 |  1.0 |   2.0 |   1.0 |  1.0 |   1.0 |   1.0 |      1.0 |     2.0 |  1.0 |    1.0 |  0.5 |   1.0 |
|      1 |      1.0 |    1.0 |    1.0 |    1.0 |  2.0 |  1.0 |   1.0 |   0.5 |  0.5 |   0.5 |   1.0 |      0.5 |     1.0 |  2.0 |    1.0 |  1.0 |   2.0 |
|      1 |      1.0 |    1.0 |    1.0 |    1.0 |  0.5 |  2.0 |   1.0 |   2.0 |  0.5 |   0.5 |   2.0 |      1.0 |     1.0 |  2.0 |    0.5 |  1.0 |   1.0 |
|      1 |      1.0 |    1.0 |    1.0 |    2.0 |  2.0 |  1.0 |   1.0 |   1.0 |  2.0 |   0.5 |   0.5 |      1.0 |     1.0 |  1.0 |    0.5 |  1.0 |   1.0 |
|      1 |      1.0 |    0.5 |    0.5 |    2.0 |  2.0 |  0.5 |   1.0 |   0.5 |  0.5 |   2.0 |   0.5 |      1.0 |     1.0 |  1.0 |    0.5 |  1.0 |   1.0 |
|      1 |      1.0 |    2.0 |    1.0 |    0.0 |  1.0 |  1.0 |   1.0 |   1.0 |  1.0 |   2.0 |   0.5 |      0.5 |     1.0 |  1.0 |    0.5 |  1.0 |   1.0 |
|      1 |      2.0 |    1.0 |    2.0 |    1.0 |  1.0 |  1.0 |   1.0 |   0.5 |  1.0 |   1.0 |   1.0 |      1.0 |     0.5 |  1.0 |    1.0 |  0.0 |   1.0 |
|      1 |      1.0 |    2.0 |    1.0 |    2.0 |  1.0 |  1.0 |   1.0 |   0.5 |  0.5 |   0.5 |   2.0 |      1.0 |     1.0 |  0.5 |    2.0 |  1.0 |   1.0 |
|      1 |      1.0 |    1.0 |    1.0 |    1.0 |  1.0 |  1.0 |   1.0 |   0.5 |  1.0 |   1.0 |   1.0 |      1.0 |     1.0 |  1.0 |    2.0 |  1.0 |   0.0 |
|      1 |      0.5 |    1.0 |    1.0 |    1.0 |  1.0 |  1.0 |   2.0 |   1.0 |  1.0 |   1.0 |   1.0 |      1.0 |     2.0 |  1.0 |    1.0 |  0.5 |   0.5 |
|      1 |      2.0 |    1.0 |    0.5 |    1.0 |  1.0 |  1.0 |   1.0 |   0.5 |  0.5 |   1.0 |   1.0 |      1.0 |     1.0 |  1.0 |    2.0 |  2.0 |   1.0 |



Offensive type chart:

| NORMAL | FIGHTING | FLYING | POISON | GROUND | ROCK |  BUG | GHOST | STEEL | FIRE | WATER | GRASS | ELECTRIC | PSYCHIC |  ICE | DRAGON | DARK | FAIRY |
| -----: | -------: | -----: | -----: | -----: | ---: | ---: | ----: | ----: | ---: | ----: | ----: | -------: | ------: | ---: | -----: | ---: | ----: |
|    1.0 |      2.0 |    1.0 |    1.0 |    1.0 |  1.0 |  1.0 |   0.0 |   1.0 |  1.0 |   1.0 |   1.0 |      1.0 |     1.0 |  1.0 |    1.0 |  1.0 |   1.0 |
|    1.0 |      1.0 |    2.0 |    1.0 |    1.0 |  0.5 |  0.5 |   1.0 |   1.0 |  1.0 |   1.0 |   1.0 |      1.0 |     2.0 |  1.0 |    1.0 |  0.5 |   2.0 |
|    1.0 |      0.5 |    1.0 |    1.0 |    0.0 |  2.0 |  0.5 |   1.0 |   1.0 |  1.0 |   1.0 |   0.5 |      2.0 |     1.0 |  2.0 |    1.0 |  1.0 |   1.0 |
|    1.0 |      0.5 |    1.0 |    0.5 |    2.0 |  1.0 |  0.5 |   1.0 |   1.0 |  1.0 |   1.0 |   0.5 |      1.0 |     2.0 |  1.0 |    1.0 |  1.0 |   0.5 |
|    1.0 |      1.0 |    1.0 |    0.5 |    1.0 |  0.5 |  1.0 |   1.0 |   1.0 |  1.0 |   2.0 |   2.0 |      0.0 |     1.0 |  2.0 |    1.0 |  1.0 |   1.0 |
|    0.5 |      2.0 |    0.5 |    0.5 |    2.0 |  1.0 |  1.0 |   1.0 |   2.0 |  0.5 |   2.0 |   2.0 |      1.0 |     1.0 |  1.0 |    1.0 |  1.0 |   1.0 |
|    1.0 |      0.5 |    2.0 |    1.0 |    0.5 |  2.0 |  1.0 |   1.0 |   1.0 |  2.0 |   1.0 |   0.5 |      1.0 |     1.0 |  1.0 |    1.0 |  1.0 |   1.0 |
|    0.0 |      0.0 |    1.0 |    0.5 |    1.0 |  1.0 |  0.5 |   2.0 |   1.0 |  1.0 |   1.0 |   1.0 |      1.0 |     1.0 |  1.0 |    1.0 |  2.0 |   1.0 |
|    0.5 |      2.0 |    0.5 |    0.0 |    2.0 |  0.5 |  0.5 |   1.0 |   0.5 |  2.0 |   1.0 |   0.5 |      1.0 |     0.5 |  0.5 |    0.5 |  1.0 |   0.5 |
|    1.0 |      1.0 |    1.0 |    1.0 |    2.0 |  2.0 |  0.5 |   1.0 |   0.5 |  0.5 |   2.0 |   0.5 |      1.0 |     1.0 |  0.5 |    1.0 |  1.0 |   0.5 |
|    1.0 |      1.0 |    1.0 |    1.0 |    1.0 |  1.0 |  1.0 |   1.0 |   0.5 |  0.5 |   0.5 |   2.0 |      2.0 |     1.0 |  0.5 |    1.0 |  1.0 |   1.0 |
|    1.0 |      1.0 |    2.0 |    2.0 |    0.5 |  1.0 |  2.0 |   1.0 |   1.0 |  2.0 |   0.5 |   0.5 |      0.5 |     1.0 |  2.0 |    1.0 |  1.0 |   1.0 |
|    1.0 |      1.0 |    0.5 |    1.0 |    2.0 |  1.0 |  1.0 |   1.0 |   0.5 |  1.0 |   1.0 |   1.0 |      0.5 |     1.0 |  1.0 |    1.0 |  1.0 |   1.0 |
|    1.0 |      0.5 |    1.0 |    1.0 |    1.0 |  1.0 |  2.0 |   2.0 |   1.0 |  1.0 |   1.0 |   1.0 |      1.0 |     0.5 |  1.0 |    1.0 |  2.0 |   1.0 |
|    1.0 |      2.0 |    1.0 |    1.0 |    1.0 |  2.0 |  1.0 |   1.0 |   2.0 |  2.0 |   1.0 |   1.0 |      1.0 |     1.0 |  0.5 |    1.0 |  1.0 |   1.0 |
|    1.0 |      1.0 |    1.0 |    1.0 |    1.0 |  1.0 |  1.0 |   1.0 |   1.0 |  0.5 |   0.5 |   0.5 |      0.5 |     1.0 |  2.0 |    2.0 |  1.0 |   2.0 |
|    1.0 |      2.0 |    1.0 |    1.0 |    1.0 |  1.0 |  2.0 |   0.5 |   1.0 |  1.0 |   1.0 |   1.0 |      1.0 |     0.0 |  1.0 |    1.0 |  0.5 |   2.0 |
|    1.0 |      0.5 |    1.0 |    2.0 |    1.0 |  1.0 |  0.5 |   1.0 |   2.0 |  1.0 |   1.0 |   1.0 |      1.0 |     1.0 |  1.0 |    0.0 |  0.5 |   1.0 |



Assuming that each pokemon has 2 types (2 types are the same if the pokemon is single-type), then all possible types combinations of a pokemon can be listed as:

```R
overall_type = tibble(
  type1 = as.vector(sapply(types, rep, 18)),
  type2 = rep(types, 18)
)
single_type_index = overall_type$type1 == overall_type$type2
overall_type$type2[single_type_index] = NA
```



For a team that allows up to N pokemon(s), the best team combination can be simulated using this function:

```R
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
```



For instance, if you are only allowed to bring on one pokemon (**n = 1**) and the pokemon that your opponent uses is completely random, bringing these pokemons (ranked from best to worst) will likely give you a type advantage.

```R
team_n1 = calculate_type_combo(1)
```

| team                | offense_sum | defense_sum | offense_ranking | defense_ranking | overall_ranking | battle_premium |
| :------------------ | ----------: | ----------: | --------------: | --------------: | --------------: | -------------: |
| GROUND&#124;STEEL   |        40.0 |        34.0 |              21 |              35 |              56 |       1.176471 |
| STEEL&#124;GROUND   |        40.0 |        34.0 |              26 |              36 |              62 |       1.176471 |
| STEEL&#124;FIRE     |        39.0 |        33.0 |              63 |              27 |              90 |       1.181818 |
| FIRE&#124;STEEL     |        39.0 |        33.0 |              65 |              28 |              93 |       1.181818 |
| FIRE&#124;FAIRY     |        39.5 |        35.5 |              43 |              65 |             108 |       1.112676 |
| STEEL&#124;FAIRY    |        38.5 |        32.5 |              88 |              21 |             109 |       1.184615 |
| FLYING&#124;STEEL   |        38.5 |        33.5 |              76 |              33 |             109 |       1.149254 |
| STEEL&#124;WATER    |        38.5 |        33.0 |              87 |              29 |             116 |       1.166667 |
| FIGHTING&#124;STEEL |        38.5 |        34.5 |              75 |              41 |             116 |       1.115942 |
| FAIRY&#124;FIRE     |        39.5 |        35.5 |              51 |              66 |             117 |       1.112676 |



Referring back to the type combos, the most advantageous type is GROUND + STEEL, followed by STEEL + FIRE. (* Obviously not all type combinations exist in the pokemon world, but this simulation is just to show theoretically the most advantagous type. At the same time, quantifying the battle premium of the types helps integrating pokemon base stats with type advantages.)



In the table shown above, offense sum is calculated by:

```R
offense_sum = offense_noeffect_n*0 + 
             offense_notveryeffective_n*0.5 + 
             offense_effective_n*1 + 
             offense_supereffective_n*2
```

defense sum is calculated by:

```R
defense_sum = defense_noeffect_n*0 + 
             defense_notveryeffective_n*0.5 + 
             defense_effective_n*1 + 
             defense_supereffective_n*2
```

**offense/defense ranking** refer to the ranking of the **offense/defense sums**; **overall ranking** is the sum of the two rankings; **battle premium** is the ratio between offense sum and defense sum. There is a strong negative correlation between battle premium and overall ranking. 



#### Run it!

Now the concept is clear, we just need to run it for n equals to 1 to 6, or:

```R
team_n1 = calculate_type_combo(1)  ## Takes a few seconds
team_n2 = calculate_type_combo(2)  ## Takes around 4 minutes
team_n3 = calculate_type_combo(3)  ## Takes a while
team_n4 = calculate_type_combo(4)  ## Takes even longer
team_n5 = calculate_type_combo(5)  ## ..
team_n6 = calculate_type_combo(6)  ## ....
```



Here is the table for N = 2:

| team                                | offense_sum | defense_sum | offense_ranking | defense_ranking | overall_ranking | battle_premium |
| :---------------------------------- | ----------: | ----------: | --------------: | --------------: | --------------: | -------------: |
| GROUND&#124;STEEL;FIRE&#124;FAIRY   |        79.5 |        69.5 |             752 |           16639 |           17391 |       1.143885 |
| GROUND&#124;STEEL;WATER&#124;FAIRY  |        79.0 |        69.5 |            1260 |           16651 |           17911 |       1.136691 |
| GROUND&#124;STEEL;FIRE&#124;WATER   |        79.5 |        70.0 |             751 |           17227 |           17978 |       1.135714 |
| GROUND&#124;GHOST;STEEL&#124;FIRE   |        78.5 |        69.0 |            2078 |           16231 |           18309 |       1.137681 |
| FLYING&#124;GROUND;STEEL&#124;FAIRY |        79.0 |        70.0 |            1106 |           17239 |           18345 |       1.128571 |
| FLYING&#124;GROUND;STEEL&#124;FIRE  |        79.5 |        70.5 |             642 |           17899 |           18541 |       1.127660 |
| FLYING&#124;GROUND;STEEL&#124;WATER |        79.0 |        70.5 |            1105 |           17911 |           19016 |       1.120567 |
| GROUND&#124;GHOST;STEEL&#124;FAIRY  |        78.0 |        68.5 |            3155 |           15943 |           19098 |       1.138686 |
| FLYING&#124;STEEL;FIRE&#124;FAIRY   |        78.0 |        69.0 |            2938 |           16243 |           19181 |       1.130435 |
| FLYING&#124;GROUND;GHOST&#124;STEEL |        78.0 |        69.5 |            2881 |           16663 |           19544 |       1.122302 |

Clearly GROUND+STEEL is very advantageous, other honorable mentions are  FIRE, FAIRY and WATER.



If any of you has the computation power or would like to spend some time optimizing the code/concept, please feel free to run the combination with three or above pokemons and chat with me!



#### Things to improve upon

- Simplify primary & secondary types to speed up the simulation.
- Considering team's weakness to one particular type (E.g. DRAGON & FLYING to ICE, I am not talking about dragonite.)
- Considering pokemon's type ratio in the real game (Some types are more commonly used in the battle). However, since pokemon battle can be considered as a zero game, you will never know what your opponent is thinking. 
- **Combining type advantages with pokemon base stats**

