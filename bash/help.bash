# Run LAMMPS (CPU)
export NP=<number_of_CPU> && apptainer run lammps-chemtrain.sif lmp in.chemtrain-deploy-bulk-tensorial

# Run LAMMPS (CUDA)
export NP=<number_of_GPU> && apptainer run --nv lammps-chemtrain-cuda.sif lmp in.chemtrain-deploy-bulk-tensorial-gpu

# Export model checkpoint to a ptb file which can be read by LAMMPS
apptainer run lammps-chemtrain.sif export -c config.yaml -ck last.cpkt
