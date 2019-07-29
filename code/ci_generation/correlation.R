install.packages('rcicr')
#installed toolbox to generate noisy Stimuli and CIs
library(rcicr)
#uploaded MNES image (male w/ neutral expression) from AKDEF (Averaged Karolinska Face Database) 
#used MNES as base image, as past reverse correlation experiments have done
#had to resize MNES image from the command line using sips
generateStimuli2IFC(base_face_files=list('im' = 'MNES.jpg'),n_trials=300, img_size = 512, stimulus_path = './stimuli', label = 'rcic', seed = 1)
#generate 300 sets of stimuli (each set has both noise and anti-noise)
citation('rcicr')


