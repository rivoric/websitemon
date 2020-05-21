#!/usr/bin/env python

"""Creates or updates the configuration tables in Azure Storage from the JSON objects passed in

The JSON should be in the following format
{
    "table_name": [
        {
            "PartitionKey": "...",
            "RowKey": "...",
            ...
        },
        {
            "PartitionKey": "...",
            "RowKey": "...",
            ...
        }
        ...
    ]
    ...
}"""

import json
import argparse
from azure.cosmosdb.table.tableservice import TableService

def update_tables(connection_string: str, configuration_files: list) -> None:
    try:
        ts = TableService(connection_string=connection_string)
    except:
        if connection_string == "UseDevelopmentStorage=true":
            print("Unable to connect to Azure Storage Emulator (is it running)")
        else:
            print("Unable to connect to storage account")
        exit(1)

    tables = [t.name for t in ts.list_tables()]

    for config_file in configuration_files:
        print("Reading file:",config_file)

        with open(config_file) as jsonfile:
            loaded_config = json.load(jsonfile)
            for table_name in loaded_config.keys():
                print("Updating table:",table_name)

                if table_name not in tables:
                    # table does not exist, create it and update list of table names
                    ts.create_table(table_name)
                    tables.append(table_name)

                for config in loaded_config[table_name]:
                    ts.insert_or_merge_entity(table_name, config)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__, prefix_chars='-/',
                    formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('configs', metavar='json', nargs='+',
                    help='JSON configuration files')
    parser.add_argument('--connection-string', '-s', dest='connstr', default="UseDevelopmentStorage=true",
                    help='connection string for the Azure Storage account (defaults to Azure Storage Emulator running on the local machine)')
    args = parser.parse_args()
    update_tables(args.connstr, args.configs)