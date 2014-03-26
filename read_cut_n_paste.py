## Read data cut-n-pasted from the web and munge it into a nice table
##
## url = http://onlineraceresults.com/race/view_race.php?race_id=38083&relist_record_type=result&lower_bound=0&upper_bound=2028&use_previous_sql=1&group_by=default#racetop

## Pasting the data into my text editor produced the unfortunate situation
## that each record was split across 3 lines. Here, we read in fields on
## each line and append them to a list of records every third line.
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

## drop the first column which holds the useless word "printradius"
records = [record[1:] for record in records]

column_names = ('NO', 'FN', 'LN', 'AGE', 'SEX', 'DIVISION', 'OVERALL', 'DIVPL', 'SEXP', 'TIME', 'PACE')

## write the cleaned up records, one per line, out to a tab separated text file
with open('data/mercer_island_half_2014_results.txt', 'w') as f:
    f.write('\t'.join(column_names) + '\n')
    f.writelines(['\t'.join(record) + '\n' for record in records])
