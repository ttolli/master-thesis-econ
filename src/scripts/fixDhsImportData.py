# A helper script to fix hard-coded paths in DHS-provided .do and .dct-files
# In .do-file, hard-coded paths are the first lines, in form of
#
# 'infix using "full_path_for_dct_file.DCT"'
#
# and in .dct-file, in a form
#
# 'infix dictionary using "full_path_for_dat_file.DAT" {'
#
# They will be fixed to match users environment
import os

def fixPaths(directory):
    for dirpath,_,filenames in os.walk(directory):
        for f in filenames:
            if f.endswith('.DO'):
                # need to replace command in first line with correct path.
                # command is in a form: 'infix using "full_path_for_dct_file.DCT"'
                fullPath = os.path.abspath(os.path.join(dirpath, f))
                dctFullPath = os.path.splitext(fullPath)[0]+'.DCT'
                lines = open(fullPath).readlines()
                commands = lines[0].split(" ")
                commands[2] = '"' + dctFullPath + '"'
                lines[0] = " ".join(commands)
                open(fullPath, "w").writelines(lines)

            if f.endswith('.DCT'):
                # need to replace command in first line with correct path.
                # command is in a form: 'infix dictionary using "full_path_for_dat_file.DAT" {'
                fullPath = os.path.abspath(os.path.join(dirpath, f))
                datFullPath = os.path.splitext(fullPath)[0]+'.DAT'
                lines = open(fullPath).readlines()
                commands = lines[0].split(" ")
                commands[3] = '"' + datFullPath + '"'
                lines[0] = " ".join(commands)
                open(fullPath, "w").writelines(lines)