#!/bin/bash
#!/bin/bash

DIR_PATH="./my_directory"
if [ -d "$DIR_PATH" ]; then
    echo "Directory '$DIR_PATH' already exists."
else
    echo "Directory '$DIR_PATH' does not exist. Creating it now..."
    mkdir -p "$DIR_PATH"
    echo "Directory created successfully."
fi
