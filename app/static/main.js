function updateQueryStringParameter(uri, key, value) {
  var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  var separator = uri.indexOf('?') !== -1 ? "&" : "?";
  if (uri.match(re)) {
    return uri.replace(re, '$1' + key + "=" + value + '$2');
  }
  else {
    return uri + separator + key + "=" + value;
  }
}

function queryStringToObj(qs) {
  var obj = {}; 
  qs.replace(/([^=&]+)=([^&]*)/g, function(m, key, value) {
    obj[decodeURIComponent(key)] = decodeURIComponent(value);
  });
  return obj;
}

String.format = function(format) {
    var args = Array.prototype.slice.call(arguments, 1);
    return format.replace(/{(\d+)}/g, function(match, number) { 
        return typeof args[number] != 'undefined'
            ? args[number] 
            : match
        ;
    });
};

var MainJs = function() {
    var that = this; //Love you javascript
    var PASTEL_CODES = ["#FFEAEA", "#E7F3F1", "#F1F1D6", "#F3E7E7", "#F9F9DD", "#FFE6D0", "#E3FBE9", "#FAFBDF"];
    
    //updownvote buttons
	_.each(Sizzle(".up-down-vote .triangle-base"), function(elem) {
		elem.addEventListener('click', function() {
            var url = Sizzle("input[name='url']", elem)[0].value;
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(e) {
                if (xhr.readyState !== XMLHttpRequest.DONE) return;
                if (xhr.status === 401) {
                    window.location.href = '/login';
                    return;
                }
                if (xhr.status !== 200) {
                    //TODO - show error toast
                    console.log(xhr.responseText);
                    return;
                }
                
                var jsonRes = JSON.parse(xhr.responseText)

                //Set net vote
                Sizzle(".updownvote-value", elem.parentNode)[0].innerHTML = jsonRes.net_vote;

                //Set color for votes
                that.setUpDownVoteColor(elem, jsonRes.my_vote);
            };
            xhr.open('POST', url);
            xhr.send();            
		});
	});

    //answer radio
    _.each(Sizzle("input[name='answer']"), function(elem) {
        elem.addEventListener('click', function() {
            var url = Sizzle("input[name='url']", elem.parentNode)[0].value;
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function(e) {
                if (xhr.readyState !== XMLHttpRequest.DONE) return;
                if (xhr.status === 401) {
                    window.location.href = '/login';
                    return;
                }
                if (xhr.status !== 200) {
                    //TODO - show error toast
                    alert(xhr.responseText);
                    return;
                }
                
                var ansVotes = JSON.parse(xhr.responseText)
                that.showVotes(ansVotes);
            };
            xhr.open('POST', url);
            xhr.send();
        });
    });

    this.setUpDownVoteColor = function(elem, amount) {
        //Clear color of both triangles
        _.each(Sizzle(".triangle-base", elem.parentNode), function(elem2) {
            elem2.style['border-bottom-color'] = "grey";
            elem2.style['border-top-color'] = "grey";
        });
        if (amount == 0)
            return;
 
        //Set color of user's vote
        var color = Sizzle("input[name='color']", elem)[0].value;
        elem.style['border-bottom-color'] = color;
        elem.style['border-top-color'] = color;
        //That was dirty! 
    };

    this.showVotes = function(ansVotes) {
        var totalVotes = _.reduce(ansVotes, function(memo, ans){
            return memo + ans.answer_net_votes;
        }, 0);

        //Show percentage votes for each answer
        var colors = _.shuffle(PASTEL_CODES);
        _.each(Sizzle("input[name='answer']"), function(elem, index) {
            var ans = _.find(ansVotes, function(ansV){
                return ansV.answer_id == elem.value;
            });
            if (ans === undefined) return; //This is a continue! Now that's not cool.

            ans.pct = Math.floor(ans.answer_net_votes * 100.0 / totalVotes);
            ans.color = colors[index%colors.length];
            bg = String.format("linear-gradient(90deg, {0} {1}%, #FFFFFF {1}%)", ans.color, ans.pct);
            //Show background
            Sizzle(String.format("#div_answer_{0}", ans.answer_id))[0].style.background = bg;
            
            //Show the circle with the number of votes
            var tmpl = Sizzle("#tmpl_vote_result_circle")[0].innerHTML;
            var circleHtml = _.template(tmpl)(ans);
            Sizzle(String.format("#div_answer_{0}_circle", ans.answer_id))[0].innerHTML = circleHtml;
            if (ans.has_user_voted) {
                elem.checked = true;
            }
        });
    };

};

//Call the function once
mainjs = new MainJs();
