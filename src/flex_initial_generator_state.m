function flexed_initial_gen_state = flex_initial_generator_state(initial_gen_state)

flexed_initial_gen_state = initial_gen_state;

flexed_initial_gen_state(flexed_initial_gen_state>0) = 24;
flexed_initial_gen_state(flexed_initial_gen_state<0) = -24;