-- VIew ist ein virtuellen zwischen ordner der nicht gespeichert wird aber anderen select übersichtlich und schneller machen kann 
-- Man muss die abfragen nicht immer neu schreiben einaml. Nimmt nicht speicher weg. 
-- Weil wir daten verbergen können die anderen nicht sehen dürfen, Join teil können wir einmal schreiben in unseren view und die anderen selecten nur druaf und es ist einfacher

CREATE VIEW coversations_incoming AS 
    SELECT co.id AS id, co.first_name AS forname ,co.last_name AS nachname, COUNT(me.id)
    FROM contact co
    LEFT JOIN conversations ON conversations.account_id = co.id
    LEFT JOIN messages_conversations mc ON mc.conversation_id = conversations.id
    LEFT JOIN messages me On me.id = mc.message_id
    GROUP BY (me.id);
-- last_message_at als datetime


CREATE VIEW vonversations AS 
    SELECT co.id AS id, co.first_name AS forname ,co.last_name AS nachname, COUNT(me.id) AS gesamtzahl, co.last_message_at AS letze_nachricht, co.last_message_direction AS letze_nachticht
    FROM contact co
    LEFT JOIN conversations ON conversations.account_id = co.id
    LEFT JOIN messages_conversations mc ON mc.conversation_id = conversations.id
    LEFT JOIN messages me On me.id = mc.message_id
    GROUP BY (me.id);

-- beim contacts würde ich bane welassen da es gegen dei normalformen verstoßt 1, 2 



