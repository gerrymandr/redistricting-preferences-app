import os

for filename in os.listdir("."):
    if filename.endswith("csv"):
        words = filename.split("_")

        i = 0
        for word in words:
            if word == "All" or word == "District":
                break
            i += 1

        newfn = ""

        for word in words[:i]:
            newfn += word.lower()

        newfn += "districtofcolumbia.csv"
        os.rename(filename, newfn)
