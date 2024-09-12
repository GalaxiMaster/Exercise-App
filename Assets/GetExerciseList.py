import os

filesSet = set()

def iterate_through_folders(root_dir):
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            filesSet.add(file)

root_dir = "images"  # replace with the directory you want to iterate through
iterate_through_folders(root_dir)
print(filesSet)