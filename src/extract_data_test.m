function [final_db_test,finished_idx,uc_samples] = ...
    extract_data_test(fullLocalParentDir,JOB_DIRNAME_PREFIX,job_output_filename,params)


finished_idx = [];
if(params.db_rand_mode)
    vec_size = 7+params.KNN;
else vec_size = 3+params.KNN;
end

[~,n_str] = unix(['ls ',fullLocalParentDir,' |grep ',JOB_DIRNAME_PREFIX,'|wc -l']);
N_jobs = str2num(n_str);
final_db_test = nan(N_jobs*params.N_samples_test,vec_size);
uc_samples = cell(N_jobs*params.N_samples_test,3);

mod_interval=50;

for i_job=1:N_jobs
    if(mod(i_job,mod_interval)==1)
        display(['Extract iteration ',num2str(i_job),' out of ',num2str(N_jobs)]);
    end
    %     try
    lsPath=[fullLocalParentDir,'/',JOB_DIRNAME_PREFIX,num2str(i_job)];
    outputFolder=what(lsPath);
    if(~isempty(outputFolder))
        numOfExistingMatFiles=length(outputFolder.mat);
        if(numOfExistingMatFiles>0) %if job finished and there's an output
            fileList=what([fullLocalParentDir,'/',JOB_DIRNAME_PREFIX,num2str(i_job)]);
            outputFileList=fileList.mat;
            for i_matFile=1:length(outputFileList)
                outputFileName = outputFileList{i_matFile};
                if(strcmp(outputFileName(end-3:end),'.mat'))
                    outputFileName = outputFileName(1:end-4);
                end
                %                         sdb=loaded_file.sample_db;
                if(strcmp(outputFileName,job_output_filename))
                    loaded_file = load([fileList.path,'/',outputFileName]);
                    final_db_test((i_job-1)*params.N_samples_test+1:i_job*params.N_samples_test,:) = loaded_file.difference_vector;
                    
                    for i_sample = 1:size(loaded_file.uc_samples,1)
                        currIdx = i_sample+(i_job-1)*params.N_samples_test;
                        uc_samples(currIdx,:) =  loaded_file.uc_samples(i_sample,:);
                    end
                    finished_idx = [finished_idx,i_job];
                end
            end
        end
    end
    %     catch ME
    %         warning(['Problem using extract_data_test for iteration = ' num2str(i_job)]);
    %         msgString = getReport(ME);
    %         display(msgString);
    %     end
end
