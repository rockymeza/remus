<html>
    <head>
        <title>PHP Test</title>
    </head>
    <body>
        <?php
             echo "Hello World";
             /* echo("Hello World"); works as well, although echo isn't a 
                function (it's a language construct). In some cases, such 
                as when multiple parameters are passed to echo, parameters 
                cannot be enclosed in parentheses */
        ?>
    </body>
</html>

<?php

$a = <<<PHP
This code should \$variable be commented
$variable->hahaha
{$this->blah['haha']}
This code should also be commented
PHP;


function getAdder($x)
{
    return function ($y) use ($x) {
        return $x + $y;
    };
}
 
$adder = getAdder(8);
echo $adder(2); // prints "10"

function lock()
{
    $file = fopen("file.txt","r+");
    retry:
    if(flock($file,LOCK_EX))
    {
        fwrite($file, "Success!");
        fclose($file);
        return 0;
    }
    else
        goto retry;
}

Class Person
{
 
    public $first;
    public $last;
 
    public function __construct($f,$l)
    {
 
        $this->first = $f;
        $this->last = $l;
 
    }
 
    public function greeting()
    {
 
        return 'Hello, my name is ' . $this->first . ' ' . $this->last . '.';
        // return 'Hello, my name is ' . $this->first . ' ' . $this->last . '.'; also works when not called from Person::greeting()
 
    }
 
}
 
$him = new Person('John','Smith');
$her = new Person('Sally','Davis');
 
echo $him->greeting(); // prints "Hello, my name is John Smith."
echo '<br>';
echo $her->greeting(); // prints "Hello, my name is Sally Davis."


