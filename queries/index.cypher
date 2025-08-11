CREATE LOOKUP INDEX rel_index IF NOT EXISTS FOR () -[r] -() ON EACH type (r);
CREATE LOOKUP INDEX input_index IF NOT EXISTS FOR () -[r:input]-() ON EACH type(r);
CREATE LOOKUP INDEX output_index IF NOT EXISTS FOR () -[r:output]-() ON EACH type(r);

// What does it mean to create an index on the return property
