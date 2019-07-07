#!/usr/bin/python

#
# usage: python filter_vcf_read_depth.py temp.vcf 20
# output: temp.vcf.filtered
# 
# Outputs a VCF file filtered by minimum read depth.
#

import sys

in_file = sys.argv[1]
depth_threshold = int(sys.argv[2])

output_file = []

with open(in_file, "r") as f:
    vcf = f.readlines()
    for line in vcf:
        if line[0] == "#":
            output_file.append(line)
        else:
            if "DP=" in line:
                start = line.find("DP=") + 3
                end = line.find(";", start)
                depth = int(line[start:end])
                if depth >= depth_threshold:
                    output_file.append(line)

with open(in_file + ".filtered", "w") as f:
    f.writelines(output_file)