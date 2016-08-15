function [final_db,sample_matrix,finished_idx] = ...
    extract_data(fullLocalParentDir,JOB_DIRNAME_PREFIX,job_output_filename,params)


[~,n_str] = unix(['ls ',fullLocalParentDir,' |grep ',JOB_DIRNAME_PREFIX,'|wc -l']);    
        N_jobs = str2num(n_str);

finished_idx = [];
sample_matrix=nan(calculate_sample_matrix_size(params,N_jobs));
final_db = cell(size(sample_matrix,2),1);


        
for i_job=1:N_jobs
    try
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
                    %
                    if(strcmp(outputFileName,job_output_filename))
                        loaded_file = load([fileList.path,'/',outputFileName]);
                        sdb=loaded_file.sample_db;
                        for i_sample = 1:length(loaded_file.sample_db)
                            vec = [sdb{i_sample}.line_status;sdb{i_sample}.windScenario(:);sdb{i_sample}.demandScenario(:)];
                            currIdx = i_sample+(i_job-1)*params.N_samples_bdb;
                            sample_matrix(:,currIdx)=vec;
                            final_db{currIdx} = sdb{i_sample};
                        end
                        finished_idx = [finished_idx,i_job];
                    end
                end
            end
        end
    catch ME
        warning(['Problem using extract_data for iteration = ' num2str(i_job)]);
        msgString = getReport(ME);
        display(msgString);
    end
end
