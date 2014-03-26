
with open('data/mercer_island_half_2014_results.cut_n_paste.txt') as f:
    records = []
    fields = []
    i = 0
    for line in f:
        i += 1
        fields.extend(line.strip().split('\t'))
        if i % 3 == 0:
            records.append(fields)
            fields = []

# the first column is the useless word "printradius"
records = [record[1:] for record in records]

column_names = ('NO', 'FN', 'LN', 'AGE', 'SEX', 'DIVISION', 'OVERALL', 'DIVPL', 'SEXP', 'TIME', 'PACE')

with open('data/mercer_island_half_2014_results.txt', 'w') as f:
    f.write('\t'.join(column_names) + '\n')
    f.writelines(['\t'.join(record) + '\n' for record in records])
