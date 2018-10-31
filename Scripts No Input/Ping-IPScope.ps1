# The base of the vlan, or the first three octets
$base = '192.168.4.'
# Your Start of the VLAN
$min = 1
# Your end of the VLAN
$max = 254

for ($i = $min; $i -lt $max; $i++) {
    $out = 'No'

    if(Test-Connection ($base + $i) -Quiet -Count 1) {
        $out = 'Yes'
    }

    Write ($base + $i) $out
}