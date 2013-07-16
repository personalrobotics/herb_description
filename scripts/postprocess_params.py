#!/usr/bin/env python
from __future__ import print_function
import argparse, lxml.etree, urlparse, sys

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Add extra properties to a URDF file.')
    parser.add_argument('--identifier', type=str, default='name', help='name')
    parser.add_argument('input_path', type=str, help='input URDF file')
    parser.add_argument('extra_path', type=str, help='attributes to add')
    parser.add_argument('output_path', type=str, nargs='?', help='output xacro file')
    args = parser.parse_args()

    with open(args.input_path, 'r') as input_file:
        urdf = lxml.etree.parse(input_file)

    with open(args.extra_path, 'r') as extra_file:
        extra = lxml.etree.parse(extra_file)

    for extra_ele in extra.getroot().getchildren():
        # Skip any tags that are missing the identifier attribute.
        if args.identifier not in extra_ele.attrib:
            continue

        id_value = extra_ele.attrib[args.identifier]
        xpath = "/{tag:s}[@{identifier:s}='{value:s}']".format(
            tag=extra_ele.tag, identifier=args.identifier, value=id_value)

        # Find the corresponding element in the URDF file.
        urdf_ele = urdf.find(xpath)

        for new_ele in extra_ele.getchildren():
            # Remove any existing tags from the URDF file.
            xpath = '{tag:s}'.format(tag=new_ele.tag)
            old_ele = urdf_ele.find(xpath)

            if old_ele is not None:
                urdf_ele.remove(old_ele)

            # Insert the new tag.
            urdf_ele.append(new_ele)

    if args.output_path is None:
        lxml.etree.dump(urdf.getroot())
    else:
        with open(args.output_path, 'w') as output_file:
            urdf.write(output_file)
