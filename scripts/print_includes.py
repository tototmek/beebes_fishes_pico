#!/usr/bin/python
import os
print("\n".join([f"#include beebes_fishes/{file}" for file in os.listdir(".") if file[-2:] == 'p8']))
