
helper <- function(){
  
  if (file.exists("data/n3_land_use.csv")){
    
    return(read_csv("data/n3_land_use.csv"))
    
  } else {
  
    #load data
    n3_land_use <- read_csv("data/land_use_full_table.csv")
    
    #edit data
    n3_land_use <- n3_land_use |> 
      mutate(Basin = case_when(is.na(Basin) ~ paste0(Region, " Region"), T ~ Basin),
             SubBasin = case_when(is.na(SubBasin) & !str_detect(Basin, "Region") ~ paste0(Basin, " Basin"),
                                  str_detect(Basin, "Region") ~ Basin,
                                  T ~ SubBasin))
    
    #select rows of interest and rename variable for ease of use
    n3_land_use <- n3_land_use |> 
      select(Region, Basin, SubBasin, Year, Landuse, LanduseKm2) |> 
      rename(Area = LanduseKm2)

    #save
    write_csv(n3_land_use, "data/n3_land_use.csv")
    
    return(n3_land_use)
      
  }
}