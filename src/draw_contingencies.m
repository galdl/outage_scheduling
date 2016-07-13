function line_status = draw_contingencies(params)

line_status = (rand(params.nl,1)>params.failure_probability);
