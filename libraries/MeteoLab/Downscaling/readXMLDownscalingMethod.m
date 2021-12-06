function method = readXMLDownscalingMethod(file)

xml = xmlread(file);

root = xml.item(0);
name = char(root.getElementsByTagName('name').item(0).getTextContent);
type = char(root.getElementsByTagName('type').item(0).getTextContent);

props = root.getElementsByTagName('property');
properties = [];
for i=1:props.getLength
    myprop = props.item(i-1);
    propName = char(myprop.getAttribute('name'));
    propValue = char(myprop.getAttribute('value'));
    properties = setfield(properties,propName,propValue);
end

method = [];
method.name = name;
method.type = type;
method.properties = properties;