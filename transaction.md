- nachrichten können geschickt und nicht ankommen der andere wartet drauf das es bei ihm ankommt.

- Wichtige inofrmationen können verloren gehen wenn nachrichten ausgetauscht werden. 

- Ein abschnisst wird zussammen ausgeführt sollte irgendwas pssien oder sein dann wird es nicht ausgeführt so verhindert man das auf eine seite was geschickt wird und auf der andere seite nichts ankommt und mails bzw. sachen einfach verloren gehen.


BEGIN TRANSACTION; 
    SELECT con.first_name, con.last_name
    FROM contacts con

    würde hier schauen das ich von messages joins mache bis ich zum tabelle contact komme und so die namen selecten würde.

    Dann würde ich case machen wo ich überprüfe gibt es eine Konversation falls nein dann 1 zurück geben falls ja dann 0
    

    dann würde ich ein insert machen mir deren werten damit sie gespeichert werden 

    dann join machen 
END TRANSACTION; 