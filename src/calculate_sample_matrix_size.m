function size = calculate_sample_matrix_size(params,N_jobs)
%return the size needed for building the sample_matrix (for UC_NN)

size = [params.nl+2*params.nb*params.horizon,N_jobs*params.N_samples_bdb];