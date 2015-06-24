%import time
%now = int(time.time())

%# If got no element, bailout
%if not elt:
%rebase("layout", title='Invalid element name')

Invalid element name

%else:

%helper = app.helper

%from shinken.macroresolver import MacroResolver

%elt_type = elt.__class__.my_type

%business_rule = False
%if elt.get_check_command().startswith('bp_rule'):
%business_rule = True
%end

%if elt_type=='host':
%breadcrumb = [ ['All hosts', '/hosts-groups'], [elt.host_name, '/host/'+elt.host_name] ]
%title = 'Host detail: ' + elt.host_name
%else:
%breadcrumb = [ ['All services', '/services-groups'], [elt.host.host_name, '/host/'+elt.host.host_name], [elt.service_description, '/service/'+elt.host.host_name+'/'+elt.service_description] ]
%title = 'Service detail: ' + elt.service_description+' on '+elt.host.host_name
%end

%rebase("layout", js=['eltdetail/js/eltdetail.js', 'eltdetail/js/jquery.color.js', 'eltdetail/js/bootstrap-switch.js', 'eltdetail/js/jquery.Jcrop.js', 'eltdetail/js/actions.js', 'eltdetail/js/graphs.js', 'eltdetail/js/custom_views.js', 'eltdetail/js/screenfull.js', 'eltdetail/js/shinken-gauge.js', 'eltdetail/js/timeline.js', 'timeline/js/timeline.js', 'eltdetail/js/history.js'], css=['eltdetail/css/bootstrap-switch.css', 'eltdetail/css/eltdetail.css', 'eltdetail/css/hide.css', 'eltdetail/css/jquery.Jcrop.css', 'eltdetail/css/shinken-gauge.css', 'timeline/css/timeline.css'], user=user, app=app, refresh=True, breadcrumb=breadcrumb, title=title)

<script type="text/javascript">
   // @mohierf@: really need this global ?
   var elt_name = '{{elt.get_full_name()}}';

   // For graph tab ...
   var html_graphes = [];
   var current_graph = '';
   var graphstart={{graphstart}};
   var graphend={{graphend}};

   $(document).ready(function(){
      // Long text truncation
      // @mohierf@: todo ... more recent bootstrap ellipsis ...
      $('.truncate_command').jTruncate({
         length: 200,
         minTrail: 0,
         moreText: "[see all]",
         lessText: "[hide extra]",
         ellipsisText: " <strong>(...)</strong>",
         moreAni: "fast",
         lessAni: 2000
      });

      $('.truncate_output').jTruncate({
         length: 200,
         minTrail: 0,
         moreText: "[see all]",
         lessText: "[hide extra]",
         ellipsisText: " <strong>(...)</strong>",
         moreAni: "fast",
         lessAni: 2000
      });

      $('.truncate_perf').jTruncate({
         length: 100,
         minTrail: 0,
         moreText: "[see all]",
         lessText: "[hide extra]",
         ellipsisText: " <strong>(...)</strong>",
         moreAni: "fast",
         lessAni: 2000
      });
  });
</script>


%# Main variables
%elt_name = elt.host_name if elt_type=='host' else elt.service_description+' on '+elt.host.host_name
%elt_display_name = elt.display_name if elt_type=='host' else elt.service_description
<div class="row container-fluid">

   <!-- First row : tags and actions ... -->
   %if elt.action_url != '' or (elt_type=='host' and len(elt.get_host_tags()) != 0) or (elt_type=='service' and len(elt.get_service_tags()) != 0) or (elt_type=='host' and len(elt.hostgroups) > 0) or (elt_type=='service' and len(elt.servicegroups) > 0):
   <div>
      %if (elt_type=='host' and len(elt.hostgroups) > 0) or (elt_type=='service' and len(elt.servicegroups) > 0):
      <div class="btn-group pull-right">
         <button class="btn btn-primary btn-xs"><i class="fa fa-sitemap"></i> Groups</button>
         <button class="btn btn-primary btn-xs dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
         <ul class="dropdown-menu pull-right">
         %if elt_type=='host':
            %for hg in elt.hostgroups:
            <li>
            <a href="/hosts-group/{{hg.get_name()}}">{{hg.get_name()}} ({{hg.alias}})</a>
            </li>
            %end
         %else:
            %for sg in elt.servicegroups:
            <li>
            <a href="/services-group/{{sg.get_name()}}">{{sg.get_name()}} ({{sg.alias}})</a>
            </li>
            %end
         %end
         </ul>
      </div>
      <div class="pull-right">&nbsp;&nbsp;</div>
      %end
      %if elt.action_url != '':
      <div class="btn-group pull-right">
         %action_urls = elt.action_url.split('|')
         <button class="btn btn-info btn-xs"><i class="fa fa-external-link"></i> {{'Action' if len(action_urls) == 1 else 'Actions'}}</button>
         <button class="btn btn-info btn-xs dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
         <!-- Do not know why but MacroResolver sometimes throws an exception !!! -->
         <ul class="dropdown-menu pull-right">
            %for action_url in helper.get_element_actions_url(elt, default_title="Url", default_icon="globe", popover=True):
            <li>{{!action_url}}</li>
            %end
         </ul>
      </div>
      <div class="pull-right">&nbsp;&nbsp;</div>
      %end
      %if hasattr(elt, 'get_host_tags') and len(elt.get_host_tags()) != 0:
      <div class="btn-group pull-right">
         %i=0
         %for t in sorted(elt.get_host_tags()):
            <a href="/all?search=htag:{{t}}"/>
               %if app.tag_as_image:
               <img src="/tag/{{t.lower()}}" alt="{{t.lower()}}" =title="Tag: {{t.lower()}}" style="height: 24px"></img>
               %else:
               <button class="btn btn-default btn-xs"><i class="fa fa-tag"></i> {{t.lower()}}</button>
               %end
            </a>
            %i=i+1
         %end
      </div>
      %end
      %if hasattr(elt, 'get_service_tags') and len(elt.get_service_tags()) != 0:
      <div id="service_tags" class="btn-group pull-right">
         <script>
            %j=0
            %for t in sorted(elt.get_service_tags()):
               var b{{j}} = $('<a href="/all?search=stag:{{t}}"/>').appendTo($('#service_tags'));
               $('<img />')
                  .attr({ 'src': '/static/images/tags/{{t.lower()}}.png', 'alt': '{{t.lower()}}', 'title': 'Tag: {{t.lower()}}' })
                  .css({height: "24px"})
                  .load(function() {
                  })
                  .error(function() {
                    $(this).remove();
                    $("<span/>").attr({ 'class': 'btn btn-default btn-xs'}).append('{{t}}').appendTo(b{{j}});
                  })
                  .appendTo(b{{j}});
               var span = $("<span/>").append('&nbsp;').appendTo($('#service_tags'));
               %j=j+1
            %end
         </script>
      </div>
      %end
   </div>
   %end

   <!-- Second row : host/service overview ... -->
   <div class="panel panel-default">
      <div class="panel-heading fitted-header cursor" data-toggle="collapse" data-parent="#Overview" href="#collapseOverview">
         <h4 class="panel-title"><span class="caret"></span>&nbsp;Overview {{elt_name}} ({{elt.display_name if elt.display_name else elt.alias if elt.alias else 'none'}}) {{!helper.get_business_impact_text(elt.business_impact)}}</h4>
      </div>
  
      <div id="collapseOverview" class="panel-body panel-collapse collapse">
         %if elt_type=='host':
         <dl class="col-sm-6 dl-horizontal">
            <dt>Alias:</dt>
            <dd>{{elt.alias}}</dd>

            <dt>Address:</dt>
            <dd>{{elt.address}}</dd>

            <dt>Importance:</dt>
            <dd>{{!helper.get_business_impact_text(elt.business_impact, True)}}</dd>
         </dl>
        
         <dl class="col-sm-6 dl-horizontal">
            <dt>Parents:</dt>
            %if len(elt.parents) > 0:
            <dd>
            %for parent in elt.parents:
            <a href="/host/{{parent.get_name()}}" class="link">{{parent.alias}} ({{parent.get_name()}})</a>
            %end
            </dd>
            %else:
            <dd>(none)</dd>
            %end


            <dt>Member of:</dt>
            %if len(elt.hostgroups) > 0:
            <dd>
            %for hg in elt.hostgroups:
            <a href="/hosts-group/{{hg.get_name()}}" class="link">{{hg.alias}} ({{hg.get_name()}})</a>
            %end
            </dd>
            %else:
            <dd>(none)</dd>
            %end

            <dt>Notes:</dt>
            <dd>
            %for note_url in helper.get_element_notes_url(elt, default_title="Note", default_icon="tag", popover=True):
               <button class="btn btn-default btn-xs">{{! note_url}}</button>
            %end
            </dd>
         </dl>
         %else:
         <dl class="col-sm-6 dl-horizontal">
            <dt>Host:</dt>
            <dd>
               <a href="/host/{{elt.host.host_name}}" class="link">{{elt.host.host_name}} ({{elt.host.display_name if elt.host.display_name else elt.host.alias if elt.host.alias else 'none'}})</a>
            </dd>

            <dt>Importance:</dt>
            <dd>{{!helper.get_business_impact_text(elt.business_impact, True)}}</dd>
         </dl>
        
         <dl class="col-sm-6 dl-horizontal">
            <dt>Member of:</dt>
            %if len(elt.servicegroups) > 0:
            <dd>
            %for sg in elt.servicegroups:
            <a href="/services-group/{{sg.get_name()}}" class="link">{{sg.alias}} ({{sg.get_name()}})</a>
            %end
            </dd>
            %else:
            <dd>(none)</dd>
            %end

            <dt>Notes: </dt>
            %if elt.notes != '' and elt.notes_url != '':
            <dd><a href="{{elt.notes_url}}" target=_blank>{{elt.notes}}</a></dd>
            %elif elt.notes == '' and elt.notes_url != '':
            <dd><a href="{{elt.notes_url}}" target=_blank>{{elt.notes_url}}</a></dd>
            %elif elt.notes != '' and elt.notes_url == '':
            <dd>{{elt.notes}}</dd>
            %else:
            <dd>(none)</dd>
            %end
         </dl>
         %end
      </div>
   </div>

   %if elt_type=='host':
   %synthesis = helper.get_synthesis(elt.services)
   %s = synthesis['services']
   %h = synthesis['hosts']
   <div class="well well-sm">
      <table class="table table-invisible">
         <tbody>
            <tr>
               <td>
                  <b>{{s['nb_elts']}} services:&nbsp;</b> 
               </td>
          
               %for state in 'ok', 'warning', 'critical', 'pending', 'unknown', 'ack', 'downtime':
               <td>
                 %label = "%s <i>(%s%%)</i>" % (s['nb_' + state], s['pct_' + state])
                 {{!helper.get_fa_icon_state_and_label(cls='service', state=state, label=label, disabled=(not s['nb_' + state]))}}
               </td>
               %end
            </tr>
         </tbody>
      </table>
   </div>
   %end

   <!-- Third row : business impact alerting ... -->
   %if elt.is_problem and elt.business_impact > 2 and not elt.problem_has_been_acknowledged:
   <div class="row" style="padding: 10px;">
      <div class="col-lg-1 font-yellow pull-left">
         <span class="medium-pulse aroundpulse">
            <span class="medium-pulse pulse"></span>
            <i class="fa fa-3x fa-bolt"></i>
         </span>
      </div>
      <div class="col-lg-11 font-white">
         %disabled = '' if not app.can_action() else 'disabled'
         %disabled_ack = '' if elt.is_problem and not elt.problem_has_been_acknowledged else 'disabled'
         %disabled_fix = '' if elt.is_problem and elt.event_handler_enabled and elt.event_handler else 'disabled'
         <p class="alert alert-critical">This element has an important impact on your business, you may <button name="bt-acknowledge" class="{{disabled_ack}} {{disabled}} btn btn-primary btn-xs" data-toggle="tooltip" data-placement="bottom" title="Acknowledge this {{elt_type}} problem">acknowledge it</button> or <button name="bt-event-handler" class="{{disabled_fix}} {{disabled}} btn btn-primary btn-xs" data-toggle="tooltip" data-placement="bottom" title="Launch the event handler for this {{elt_type}}">try to fix it</button>.</p>
      </div>
   </div>
   %end
  
   <!-- Third row (bis) : business rule ... -->
   %if business_rule:
   <div class="row" style="padding: 10px;">
      <div class="col-lg-2 hidden-md"></div>
      <div class="col-lg-8 col-md-12">
         <div class="col-lg-1 pull-left">
            <span class="medium-pulse aroundpulse">
               <span class="medium-pulse pulse"></span>
               <i class="fa fa-2x fa-university"></i>
            </span>
         </div>
         <div class="col-lg-11 font-white">
            <p class="alert alert-warning">This element is a business rule.</p>
         </div>
      </div>
      <div class="col-lg-2 hidden-md"></div>
   </div>
   %end
  
   <!-- Fourth row : host/service information -->
   <div class="well well-sm">
      <!-- Detail info box start -->
         <ul class="nav nav-tabs">
            %_go_active = 'active'
            %if params['tab_custom_views']=='yes':
            %for cvname in elt.custom_views:
            <li class="{{_go_active}} cv_pane" data-name="{{cvname}}" data-element='{{elt.get_full_name()}}' id='tab-cv-{{cvname}}'><a href="#cv{{cvname}}" data-toggle="tab">{{cvname.capitalize()}}</a></li>
               %_go_active = ''
            %_go_active = ''
            %end
            %end

            %if params['tab_information']=='yes':
            <li><a href="#information" data-toggle="tab">Information</a></li>
            %end
            %if params['tab_impacts']=='yes':
            <li><a href="#impacts" data-toggle="tab">Impacts</a></li>
            %end
            %if params['tab_configuration']=='yes':
            <li><a href="#configuration" data-toggle="tab">Configuration</a></li>
            %end
            %if params['tab_commands']=='yes' and app.can_action():
            <li><a href="#commands" data-toggle="tab">Commands</a></li>
            %end
            
            %if params['tab_comments']=='yes':
            <li><a class='link_to_tab' href="#comments" data-toggle="tab">Comments</a></li>
            %end
            %if params['tab_downtimes']=='yes':
            <li><a class='link_to_tab' href="#downtimes" data-toggle="tab">Downtimes</a></li>
            %end
            
            %if params['tab_timeline']=='yes':
            <li class="timeline_pane"><a class="link_to_tab" href="#timeline" data-toggle="tab" id="tab_to_timeline">Timeline</a></li>
            %end
            %if params['tab_graphs']=='yes':
            <li><a class="link_to_tab" href="#graphs" data-toggle="tab" id="tab_to_graphs">Graphs</a></li>
            %end
            %if params['tab_depgraph']=='yes':
            <li><a class="link_to_tab" href="#depgraph" data-toggle="tab" id="tab_to_depgraph">Impact graph</a></li>
            %end
            %if params['tab_history']=='yes':
            <li class="history_pane"><a class="link_to_tab" href="#history" data-toggle="tab" id="tab_to_history">History</a></li>
            %end
            %if params['tab_counters']=='yes':
            <li class="counters_pane"><a class="link_to_tab" href="#counters" data-toggle="tab" id="tab_to_counters">Counters</a></li>
            %end
         </ul>
         
         <div class="tab-content">
            <!-- Tab custom views -->
            %if params['tab_custom_views']=='yes':
            %_go_active = 'active'
            %_go_fadein = 'in'
            %cvs = []
            %[cvs.append(item) for item in elt.custom_views if item not in cvs]
            %for cvname in cvs:
            <div class="tab-pane fade {{_go_active}} {{_go_fadein}}" data-name="{{cvname}}" data-element="{{elt.get_full_name()}}" id="cv{{cvname}}">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>Custom view {{cvname}}:</h4>
                  </div>
     
                  <div class="panel-body">
                     Cannot load the pane {{cvname}}.
                  </div>
               </div>
            </div>
            %_go_active = ''
            %_go_fadein = ''
            %end
            %end
            <!-- Tab custom views end -->

            <!-- Tab Information start-->
            %if params['tab_information']=='yes':
            <div class="tab-pane fade" id="information">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} information:</h4>
                  </div>
     
                  <div class="panel-body">
                     <div class="col-lg-6">
                        <table class="table table-condensed">
                           <colgroup>
                              <col style="width: 40%" />
                              <col style="width: 60%" />
                           </colgroup>
                           <thead>
                              <tr>
                                 <th colspan="2">Status:</td>
                              </tr>
                           </thead>
                           <tbody style="font-size:x-small;">
                              <tr>
                                 <td><strong>Status:</strong></td>
                                 <td>
                                    {{! helper.get_fa_icon_state(obj=elt, label='title')}}
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Since:</strong></td>
                                 <td>
                                    {{! helper.print_duration(elt.last_state_change, just_duration=True, x_elts=2)}}
                                 </td>
                              </tr>
                           </tbody>
                        </table>
                   
                        <table class="table table-condensed table-nowrap">
                           <colgroup>
                              <col style="width: 40%" />
                              <col style="width: 60%" />
                           </colgroup>
                           <thead>
                              <tr>
                                 <th colspan="2">Last check:</td>
                              </tr>
                           </thead>
                           <tbody style="font-size:x-small;">
                              <tr>
                                 <td><strong>Last Check:</strong></td>
                                 <td><span class="quickinfo" data-original-title='Last check was at {{time.asctime(time.localtime(elt.last_chk))}}'>was {{helper.print_duration(elt.last_chk)}}</span></td>
                              </tr>
                              <tr>
                                 <td><strong>Output:</strong></td>
                                 <td class="popover-dismiss" 
                                       data-html="true" data-toggle="popover" data-trigger="hover" data-placement="bottom" 
                                       data-title="{{elt.get_full_name()}} check output" 
                                       data-content=" {{elt.output}}{{'<br/>'+elt.long_output.replace('\n', '<br/>') if elt.long_output else ''}}"
                                       >
                                  {{!helper.strip_html_output(elt.output[:app.max_output_length]) if app.allow_html_output else elt.output[:app.max_output_length]}}
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Performance data:</strong></td>
                                 <td class="popover-dismiss ellipsis" 
                                       data-html="true" data-toggle="popover" data-trigger="hover" data-placement="bottom" 
                                       data-title="{{elt.get_full_name()}} performance data" 
                                       data-content=" {{elt.perf_data if len(elt.perf_data) > 0 else '(none)'}}"
                                       >
                                  {{elt.perf_data if len(elt.perf_data) > 0 else '(none)'}}
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Check latency / duration:</strong></td>
                                 <td>
                                    {{'%.2f' % elt.latency}} / {{'%.2f' % elt.execution_time}} seconds
                                 </td>
                              </tr>
                              
                              <tr>
                                 <td><strong>Last State Change:</strong></td>
                                 <td>{{time.asctime(time.localtime(elt.last_state_change))}}</td>
                              </tr>
                              <tr>                             
                                 <td><strong>Current Attempt:</strong></td>
                                 <td>{{elt.attempt}}/{{elt.max_check_attempts}} ({{elt.state_type}} state)</td>
                              </tr>
                              <tr>     
                                 <td><strong>Next Active Check:</strong></td>
                                 <td><span class="quickinfo" data-original-title='Next active check at {{time.asctime(time.localtime(elt.next_chk))}}'>{{helper.print_duration(elt.next_chk)}}</span></td>
                              </tr>
                           </tbody>
                        </table>
                              
                        <table class="table table-condensed">
                           <colgroup>
                              <col style="width: 40%" />
                              <col style="width: 60%" />
                           </colgroup>
                           <thead>
                              <tr>
                                 <th colspan="2">Checks configuration:</td>
                              </tr>
                           </thead>
                           <tbody style="font-size:x-small;">
                              <tr>
                                 <td><strong>Check period:</strong></td>
                                 %tp=app.get_timeperiod(elt.check_period.get_name())
                                 <td name="check_period" class="popover-dismiss" 
                                       data-html="true" data-toggle="popover" data-trigger="hover" data-placement="left" 
                                       data-title='{{tp.alias if hasattr(tp, "alias") else tp.timeperiod_name}}' 
                                       data-content='{{!helper.get_timeperiod_html(tp)}}'
                                       >
                                 {{! app.helper.get_on_off(elt.check_period.is_time_valid(now), 'Is element check period currently active?')}}
                                 <a href="/timeperiods">{{elt.check_period.alias}}</a>
                                 </td>
                              </tr>
                              %if elt.maintenance_period is not None:
                              <tr>
                                 <td><strong>Maintenance period:</strong></td>
                                 <td name="maintenance_period" class="popover-dismiss" 
                                       data-html="true" data-toggle="popover" data-trigger="hover" data-placement="left" 
                                       data-title='{{tp.alias if hasattr(tp, "alias") else tp.timeperiod_name}}'
                                       data-content='{{!helper.get_timeperiod_html(tp)}}'
                                       >
                                 {{! app.helper.get_on_off(elt.maintenance_period.is_time_valid(now), 'Is element maintenance period currently active?')}}
                                 <a href="/timeperiods">{{elt.maintenance_period.alias}}</a>
                                 </td>
                              </tr>
                              %end
                              <tr>
                                 <td><strong>Check command:</strong></td>
                                 <td class="truncate_command">
                                 %try:
                                    {{ MacroResolver().resolve_simple_macros_in_string(elt.get_check_command(), elt.get_data_for_checks()) }}
                                 %except:
                                    {{elt.get_check_command()}}
                                 %end
                                 </td>
                                 <td>
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Active checks:</strong></td>
                                 <td>{{! app.helper.get_on_off(elt.active_checks_enabled, 'Is active checking enabled?')}}</td>
                              </tr>
                              %if (elt.active_checks_enabled):
                              <tr>
                                 <td><strong>Check interval:</strong></td>
                                 <td>{{elt.check_interval}} minutes</td>
                              </tr>
                              <tr>
                                 <td><strong>Retry interval:</strong></td>
                                 <td>{{elt.retry_interval}} minutes</td>
                              </tr>
                              <tr>
                                 <td><strong>Max check attempts:</strong></td>
                                 <td>{{elt.max_check_attempts}}</td>
                              </tr>
                              %end
                              <tr>
                                 <td><strong>Passive checks:</strong></td>
                                 <td>{{! app.helper.get_on_off(elt.passive_checks_enabled, 'Is passive checking enabled?')}}</td>
                              </tr>
                              %if (elt.passive_checks_enabled):
                              <tr>
                                 <td><strong>Freshness check:</strong></td>
                                 <td>{{! app.helper.get_on_off(elt.check_freshness, 'Is freshness check enabled?')}}</td>
                              </tr>
                              %if (elt.check_freshness):
                              <tr>
                                 <td><strong>Freshness threshold:</strong></td>
                                 <td>{{elt.freshness_threshold}} seconds</td>
                              </tr>
                              %end
                              %end
                              <tr>
                                 <td><strong>Process performance data:</strong></td>
                                 <td>{{! app.helper.get_on_off(elt.process_perf_data, 'Is perfdata process enabled?')}}</td>
                              </tr>
                              <tr>
                                 <td><strong>Event handler enabled:</strong></td>
                                 <td>{{! app.helper.get_on_off(elt.event_handler_enabled, 'Is event handler enabled?')}}</td>
                              </tr>
                              %if elt.event_handler_enabled and elt.event_handler:
                              <tr>
                                 <td><strong>Event handler:</strong></td>
                                 <td>
                                    {{ elt.event_handler.get_name() }}
                                 </td>
                              </tr>
                              %end
                           </tbody>
                        </table>
                     </div>
                     <div class="col-lg-6">
                        <table class="table table-condensed">
                           <colgroup>
                              <col style="width: 40%" />
                              <col style="width: 60%" />
                           </colgroup>
                           <thead>
                              <tr>
                                 <th colspan="2">Flapping detection:</td>
                              </tr>
                           </thead>
                           <tbody style="font-size:x-small;">
                              <tr>
                                 <td><strong>Flapping detection:</strong></td>
                                 <td>{{! app.helper.get_on_off(elt.flap_detection_enabled, 'Is status flapping detection enabled?')}}</td>
                              </tr>
                              %if elt.flap_detection_enabled:
                              <tr>
                                 <td><strong>Options:</strong></td>
                                 <td>{{', '.join(elt.flap_detection_options)}}</td>
                              </tr>
                              <tr>
                                 <td><strong>Low threshold:</strong></td>
                                 <td>{{elt.low_flap_threshold}}</td>
                              </tr>
                              <tr>
                                 <td><strong>High threshold:</strong></td>
                                 <td>{{elt.high_flap_threshold}}</td>
                              </tr>
                              %end
                           </tbody>
                        </table>

                        <table class="table table-condensed">
                           <colgroup>
                              <col style="width: 40%" />
                              <col style="width: 60%" />
                           </colgroup>
                           <thead>
                              <tr>
                                 <th colspan="2">Notifications:</td>
                              </tr>
                           </thead>
                           <tbody style="font-size:x-small;">
                              <tr>
                                 <td><strong>Notifications:</strong></td>
                                 <td>{{! app.helper.get_on_off(elt.notifications_enabled, "Are notifications enabled for this element?")}}</td>
                              </tr>
                              %if elt.notifications_enabled and elt.notification_period:
                              <tr>
                                 <td><strong>Notification period:</strong></td>
                                 %tp=app.get_timeperiod(elt.notification_period.get_name())
                                 <td name="notification_period" class="popover-dismiss" data-html="true" data-toggle="popover" data-trigger="hover" data-placement="left" 
                                       data-title='{{tp.alias if hasattr(tp, "alias") else tp.timeperiod_name}}' 
                                       data-content='{{!helper.get_timeperiod_html(tp)}}'>
                                    {{! app.helper.get_on_off(elt.notification_period.is_time_valid(now), 'Is element notification period currently active?')}}
                                    <a href="/timeperiods">{{elt.notification_period.alias}}</a>
                                 </td>
                              </tr>
                              <tr>
                                 %if elt_type=='host':
                                    %message = {}
                                    %# [d,u,r,f,s,n]
                                    %message['d'] = 'Down'
                                    %message['u'] = 'Unreachable'
                                    %message['r'] = 'Recovery'
                                    %message['f'] = 'Flapping'
                                    %message['s'] = 'Downtimes'
                                    %message['n'] = 'None'
                                 %else:
                                    %message = {}
                                    %# [w,u,c,r,f,s,n]
                                    %message['w'] = 'Warning'
                                    %message['u'] = 'Unknown'
                                    %message['c'] = 'Critical'
                                    %message['r'] = 'Recovery'
                                    %message['f'] = 'Flapping'
                                    %message['s'] = 'Downtimes'
                                    %message['n'] = 'None'
                                 %end
                                 <td><strong>Notification options:</strong></td>
                                 <td>
                                 %for m in message:
                                    {{! app.helper.get_on_off(m in elt.notification_options, '', message[m]+'&nbsp;')}}
                                 %end
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Last notification:</strong></td>
                                 <td>{{helper.print_date(elt.last_notification)}} (notification {{elt.current_notification_number}})</td>
                              </tr>
                              <tr>
                                 <td><strong>Notification interval:</strong></td>
                                 <td>{{elt.notification_interval}} mn</td>
                              </tr>
                              <tr>
                                 <td><strong>Contacts:</strong></td>
                                 %contacts=[]
                                 %[contacts.append('<a href="/contact/'+item.contact_name+'">'+item.alias+'</a>' if item.alias else item.get_name()) for item in elt.contacts if item not in contacts]
                                 <td>{{!', '.join(contacts)}}</td>
                              </tr>
                              <tr>
                                 <td><strong>Contacts groups:</strong></td>
                                 <td></td>
                              </tr>
                              %i=0
                              %for (group) in elt.contact_groups: 
                              <tr>
                                 %cg = app.get_contactgroup(group)
                                 <td style="text-align: right; font-style: italic;"><strong>{{cg.alias if cg.alias else cg.get_name()}}</strong></td>
                                 %contacts=[]
                                 %[contacts.append('<a href="/contact/'+item.contact_name+'">'+item.alias+'</a>' if item.alias else item.get_name()) for item in cg.members if item not in contacts]
                                 <td>{{!', '.join(contacts)}}</td>
                                 %i=i+1
                              </tr>
                              %end
                              %end
                           </tbody>
                        </table>
                     </div>
                  </div>
               </div>
            </div>
            %end
            <!-- Tab Information end -->

             <!-- Tab Impacts start -->
            %if params['tab_impacts']=='yes':
            <div class="tab-pane fade {{_go_active}} {{_go_fadein}}" id="impacts">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()+' impacts'}}{{' and services' if elt_type=='host' else ''}}:</h4>
                  </div>
     
                  <div class="panel-body">
                     <div class="{{'col-lg-6'}} if elt_type =='host' else 'col-lg-12'">
                        <!-- Show our father dependencies if we got some -->
                        %if len(elt.parent_dependencies) > 0:
                        <h4>Root cause:</h4>
                        {{!helper.print_business_rules(app.datamgr.get_business_parents(elt), source_problems=elt.source_problems)}}
                        %end

                        <!-- If we are an host and not a problem, show our services -->
                        %if elt_type=='host' and not elt.is_problem:
                        %if len(elt.services) > 0:
                        <h4>My services:</h4>
                        <div class="host-services">
                          {{!helper.print_aggregation_tree(helper.get_host_service_aggregation_tree(elt, app), helper.get_html_id(elt))}}
                        </div>
                        %elif len(elt.parent_dependencies) == 0:
                        <h4>No services!</h4>
                        %end
                        %end #of the only host part

                        <!-- If we are a root problem and got real impacts, show them! -->
                        %if elt.is_problem and len(elt.impacts) != 0:
                        <h4>My impacts:</h4>
                        <div class='host-services'>
                           %s = ""
                           <ul>
                           %for svc in helper.get_impacts_sorted(elt):
                              %s += "<li>"
                              %s += helper.get_fa_icon_state(svc)
                              %s += helper.get_link(svc, short=True)
                              %s += "(" + helper.get_business_impact_text(svc.business_impact) + ")"
                              %s += """ is <span class="font-%s"><strong>%s</strong></span>""" % (svc.state.lower(), svc.state)
                              %s += " since %s" % helper.print_duration(svc.last_state_change, just_duration=True, x_elts=2)
                              %s += "</li>"
                           %end
                           {{!s}}
                           </ul>
                        </div>
                        %# end of the 'is problem' if
                        %end
                     </div>
                     %if elt_type=='host':
                     <div class="col-lg-6">
                        <!-- Show our own services  -->
                        <h4>My services:</h4>
                        <div>
                          {{!helper.print_aggregation_tree(helper.get_host_service_aggregation_tree(elt, app), helper.get_html_id(elt))}}
                        </div>
                     </div>
                     %end
                  </div>
               </div>
            </div>
            %end
            <!-- Tab Impacts end -->

           <!-- Tab Configuration start -->
            %if params['tab_configuration']=='yes':
            <div class="tab-pane fade" id="configuration">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} configuration:</h4>
                  </div>
     
                  <div class="panel-body">
                     %if len(elt.customs) > 0:
                     <table class="table table-condensed table-bordered">
                        <colgroup>
                           %if app.can_action():
                           <col style="width: 30%" />
                           <col style="width: 60%" />
                           <col style="width: 10%" />
                           %else:
                           <col style="width: 40%" />
                           <col style="width: 60%" />
                           %end
                        </colgroup>
                        <thead>
                           <tr>
                              <th colspan="3">Customs:</td>
                           </tr>
                        </thead>
                        <tbody style="font-size:x-small;">
                        %for var in sorted(elt.customs):
                           <tr>
                              <td>{{var}}</td>
                              <td>{{elt.customs[var]}}</td>
                              %if app.can_action():
                              <td>
                                 <button class="{{'disabled' if not app.can_action() else ''}} btn btn-primary btn-sm" 
                                       action="change-variable"
                                       data-toggle="tooltip" data-placement="bottom" title="Change a custom variable for this {{elt_type}}"
                                       data-element="{{helper.get_uri_name(elt)}}" data-variable="{{var}}" data-value="{{elt.customs[var]}}"
                                       >
                                    <i class="fa fa-gears"></i> Change 
                                 </button>
                              </td>
                              %end
                           </tr>
                        %end
                        </tbody>
                     </table>
                     %end
                  </div>
               </div>
            </div>
            %end
            <!-- Tab Configuration end -->
            
            <!-- Tab Commands start -->
            %if params['tab_commands']=='yes' and app.can_action():
            <div class="tab-pane fade" id="commands">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} commands:</h4>
                  </div>
     
                  <div class="panel-body">
                     <div class="col-sm-6">
                     <table class="table table-condensed">
                        <colgroup>
                           <col style="width: 40%" />
                           <col style="width: 60%" />
                        </colgroup>
                        <tbody style="font-size:x-small;">
                           <tr> <!-- Add a comment -->
                              <td></td>
                              <td>
                                 %disabled_s = ''
                                 <button name="bt-add-comment" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Add a comment for this {{elt_type}}"><i class="fa fa-check"></i> Add a comment</button>
                              </td>
                           </tr>
                           
                           <tr> <!-- Try to fix -->
                              <td></td>
                              <td>
                                 %disabled_s = '' if elt.is_problem and elt.event_handler_enabled and elt.event_handler else 'disabled'
                                 <button name="bt-event-handler" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Launch the event handler for this {{elt_type}}"><i class="fa fa-magic"></i> Try to fix problem</button>
                                 <script>
                                    $('button[name="bt-event-handler"]').click(function () {
                                       try_to_fix('{{elt.get_full_name()}}');
                                    });
                                 </script>
                              </td>
                           </tr>
                           
                           <tr> <!-- Acknowledge / unacknowledge -->
                           %if elt.state != elt.ok_up and not elt.problem_has_been_acknowledged:
                              <td></td>
                              <td>
                                 %disabled_s = '' if elt.state != elt.ok_up and not elt.problem_has_been_acknowledged else 'disabled'
                                 <button id="bt-acknowledge" name="bt-acknowledge" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Acknowledge this {{elt_type}} problem"><i class="fa fa-check"></i> Add an acknowledgement</button>
                                 <script>
                                    $('button[name="bt-acknowledge"]').click(function () {
                                       stop_refresh();
                                       $('#modal').modal({
                                          keyboard: true,
                                          show: true,
                                          backdrop: 'static',
                                          remote: "/forms/acknowledge/{{helper.get_uri_name(elt)}}"
                                       });
                                    });
                                 </script>
                              </td>
                           %else:
                              <td></td>
                              <td>
                                 %disabled_s = '' if elt.problem_has_been_acknowledged else 'disabled'
                                 <button id="bt-acknowledge" name="bt-acknowledge" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Acknowledge this {{elt_type}} problem"><i class="fa fa-check"></i> Remove acknowledgement</button>
                                 <script>
                                    $('button[name="bt-acknowledge"]').click(function () {
                                       delete_acknowledge('{{elt.get_full_name()}}');
                                    });
                                 </script>
                              </td>
                           %end
                           </tr>
                           
                           <tr> <!-- Launch check -->
                              <td></td>
                              <td>
                                 %disabled_s = '' if elt.active_checks_enabled else 'disabled'
                                 <button id="bt-recheck" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Launch a check for this {{elt_type}} now"><i class="fa fa-refresh"></i> Recheck now</button>
                                 <script>
                                    $('#bt-recheck').click(function () {
                                       recheck_now('{{elt.get_full_name()}}');
                                    });
                                 </script>
                              </td>
                           </tr>
                           
                           <tr> <!-- Submit check result -->
                              <td></td>
                              <td>
                                 %disabled_s = '' if elt.passive_checks_enabled else 'disabled'
                                 <button name="bt-check-result" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Submit a check result for this {{elt_type}}"><i class="fa fa-share"></i> Submit a check result</button>
                                 <script>
                                    $('button[name="bt-check-result"]').click(function () {
                                       stop_refresh();
                                       $('#modal').modal({
                                          keyboard: true,
                                          show: true,
                                          backdrop: 'static',
                                          remote: "/forms/submit_check/{{helper.get_uri_name(elt)}}"
                                       });
                                    });
                                 </script>
                              </td>
                           </tr>
                           
                           <tr> <!-- Send a custom notification -->
                              <td></td>
                              <td>
                                 %disabled_s = 'disabled'
                                 <button id="bt-custom-notification" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Send a custom notification for this {{elt_type}}">Send a custom notification</button>
                                 <script>
                                    $('#bt-custom-notification').click(function () {
                                    });
                                 </script>
                              </td>
                           </tr>

                           <tr> <!-- Change custom variable -->
                              <td></td>
                              <td>
                                 %disabled_s = ''
                                 <button id="bt-custom-var" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Change a custom variable for this {{elt_type}}"><i class="fa fa-gears"></i> Change a custom variable</button>
                                 <script>
                                    $('#bt-custom-var').click(function () {
                                       stop_refresh();
                                       $('#modal').modal({
                                          keyboard: true,
                                          show: true,
                                          backdrop: 'static',
                                          remote: "/forms/custom_var/{{helper.get_uri_name(elt)}}"
                                       });
                                    });
                                 </script>
                              </td>
                           </tr>
                           
                           <tr> <!-- Schedule a downtime -->
                              <td></td>
                              <td>
                                 %disabled_s = ''
                                 <button id="bt-schedule-downtime" name="bt-schedule-downtime" class="col-lg-12 {{disabled_s}} btn btn-primary btn-sm" data-toggle="tooltip" data-placement="bottom" title="Schedule a downtime for this {{elt_type}}"><i class="fa fa-ambulance"></i> Schedule a downtime</button>
                              </td>
                           </tr>
                        </tbody>
                     </table>
                     </div>
                     <div class="col-sm-6">
                        <table class="table table-condensed">
                           <colgroup>
                              <col style="width: 40%" />
                              <col style="width: 60%" />
                           </colgroup>
                           <tbody style="font-size:x-small;">
                              <tr>
                                 <td><strong>Active checks enabled:</strong></td>
                                 <td>
                                    <input type="checkbox" class="switch" id="ck-active-checks" {{'checked' if elt.active_checks_enabled else ''}} >
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Passive checks enabled:</strong></td>
                                 <td>
                                    <input type="checkbox" class="switch" id="ck-passive-checks" {{'checked' if elt.passive_checks_enabled else ''}} >
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Check freshness enabled:</strong></td>
                                 <td>
                                    <input type="checkbox" class="switch" id="ck-check-freshness" {{'checked' if elt.check_freshness else ''}} >
                                 </td>
                              </tr>
                              
                              <tr>
                                 <td><strong>Notifications enabled:</strong></td>
                                 <td>
                                    <input type="checkbox" class="switch" id="ck-notifications" {{'checked' if elt.notifications_enabled else ''}} >
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Event handler enabled:</strong></td>
                                 <td>
                                    <input type="checkbox" class="switch" id="ck-event-handler" {{'checked' if elt.event_handler_enabled else ''}} >
                                 </td>
                              </tr>
                              <tr>
                                 <td><strong>Flap detection enabled:</strong></td>
                                 <td>
                                    <input type="checkbox" class="switch" id="ck-flap-detection" {{'checked' if elt.flap_detection_enabled else ''}} >
                                 </td>
                              </tr>
                           </tbody>
                        </table>
                     </div>
                  </div>
               </div>
            </div>
            %end
            <!-- Tab Commands end -->

            <!-- Tab Comments start -->
            %if params['tab_comments']=='yes':
            <div class="tab-pane fade" id="comments">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} comments:</h4>
                  </div>
     
                  <div class="panel-body">
                     %if len(elt.comments) > 0:
                     <table class="table table-condensed table-hover">
                        <thead>
                           <tr>
                              <th class="col-lg-2">Author</th>
                              <th class="col-lg-6">Comment</th>
                              <th class="col-lg-3">Date</th>
                              <th class="col-lg-1"></th>
                           </tr>
                        </thead>
                        <tbody>
                        %for c in elt.comments:
                           <tr>
                              <td>{{c.author}}</td>
                              <td>{{c.comment}}</td>
                              <td>{{helper.print_date(c.entry_time)}} - {{helper.print_date(c.expire_time)}}</td>
                              <td>
                                 <button class="{{'disabled' if not app.can_action() else ''}} btn btn-primary btn-sm" 
                                       action="delete-comment"
                                       data-toggle="tooltip" data-placement="bottom" title="Delete the comment '{{c.id}}' for this {{elt_type}}"
                                       data-element="{{helper.get_uri_name(elt)}}" data-comment="{{c.id}}"
                                       >
                                    <i class="fa fa-trash-o"></i> 
                                 </button>
                              </td>
                           </tr>
                        %end
                        </tbody>
                     </table>

                     %else:
                     <div class="alert alert-info">
                        <p class="font-blue">No comments available.</p>
                     </div>
                     %end
                     
                     <button class="{{'disabled' if not app.can_action() else ''}} btn btn-primary btn-sm" 
                           action="add-comment"
                           data-toggle="tooltip" data-placement="bottom" title="Add a comment for this {{elt_type}}"
                           data-element="{{helper.get_uri_name(elt)}}" 
                           >
                        <i class="fa fa-plus"></i> Add a comment
                     </button>
                     <button class="{{'disabled' if not app.can_action() else ''}} btn btn-primary btn-sm" 
                           action="delete-comments"
                           data-toggle="tooltip" data-placement="bottom" title="Delete all the comments of this {{elt_type}}"
                           data-element="{{helper.get_uri_name(elt)}}" 
                           >
                        <i class="fa fa-minus"></i> Delete all comments
                     </button>
                  </div>
                  
               </div>
            </div>
            %end
            <!-- Tab Comments end -->

            <!-- Tab Downtimes start -->
            %if params['tab_downtimes']=='yes':
            <div class="tab-pane fade" id="downtimes">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} downtimes:</h4>
                  </div>
     
                  <div class="panel-body">
                     %if len(elt.downtimes) > 0:
                     <table class="table table-condensed table-bordered">
                       <thead>
                        <tr>
                          <th class="col-lg-2">Author</th>
                          <th class="col-lg-5">Reason</th>
                          <th class="col-lg-5">Period</th>
                          <th class="col-lg-1"></th>
                        </tr>
                       </thead>
                       <tbody>
                        %for dt in elt.downtimes:
                        <tr>
                          <td>{{dt.author}}</td>
                          <td>{{dt.comment}}</td>
                          <td>{{helper.print_date(dt.start_time)}} - {{helper.print_date(dt.end_time)}}</td>
                          <td><a class="fa fa-trash-o {{'disabled' if not app.can_action() else ''}} font-red" href="javascript:delete_downtime('{{elt.get_full_name()}}', {{dt.id}})"></a></td>
                        </tr>
                        %end
                       </tbody>
                     </table>
                     %else:
                     <div class="alert alert-info">
                        <p class="font-blue">No downtimes available.</p>
                     </div>
                     %end
                  
                     <button name="bt-schedule-downtime" data-element="{{helper.get_uri_name(elt)}}" data-toggle="modal" data-target="#modal" class="btn btn-primary btn-sm"><i class="fa fa-plus"></i> Add a downtime</button>
                     <button name="bt-delete-downtimes" data-element="{{helper.get_uri_name(elt)}}" data-toggle="modal" data-target="#modal" class="btn btn-primary btn-sm"><i class="fa fa-minus"></i> Delete all downtimes</button>

                     </div>
                  </div>
               </div>
            %end
            <!-- Tab Downtimes end -->

            <!-- Tab Timeline start -->
            %if params['tab_timeline']=='yes':
            <div class="tab-pane fade" id="timeline">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} timeline:</h4>
                  </div>
     
                  <div class="panel-body">
                     <div id="inner_timeline" data-elt-name='{{elt.get_full_name()}}'>
                        <span class="alert alert-error">Sorry, I cannot load the timeline graph!</span>
                     </div>
                  </div>
               </div>
            </div>
            %end
            <!-- Tab Graph end -->

            <!-- Tab Graph start -->
            %if params['tab_graphs']=='yes':
            <div class="tab-pane fade" id="graphs">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} graphs:</h4>
                  </div>
     
                  <div class="panel-body">
                     %# Set source as '' or module ui-graphite will try to fetch templates from default 'detail'
                     %uris = app.get_graph_uris(elt, graphstart, graphend)
                     %if len(uris) == 0:
                     <div class="alert alert-info">
                         <div class="font-blue"><strong>Oh snap!</strong> No graphs available!</div>
                     </div>
                     %else:
                     <!-- <h4>Graphs</h4> -->
                     <div class='well'>
                        <!-- Get the uris for the 5 standard time ranges in advance  -->
                        %fourhours = now - 3600*4
                        %lastday =   now - 86400
                        %lastweek =  now - 86400*7
                        %lastmonth = now - 86400*31
                        %lastyear =  now - 86400*365

                        <ul id="graph_periods" class="nav nav-pills nav-justified">
                          <li class="active"><a href="#" data-type="graph" data-period="4h" data-graphend="{{now}}" data-graphstart="{{fourhours}}"  > 4 hours</a></li>
                          <li><a href="#" data-type="graph" data-period="1d" data-graphend="{{now}}" data-graphstart="{{lastday}}"    > 1 day</a></li>
                          <li><a href="#" data-type="graph" data-period="1w" data-graphend="{{now}}" data-graphstart="{{lastweek}}"   > 1 week</a></li>
                          <li><a href="#" data-type="graph" data-period="1m" data-graphend="{{now}}" data-graphstart="{{lastmonth}}"  > 1 month</a></li>
                          <li><a href="#" data-type="graph" data-period="1y" data-graphend="{{now}}" data-graphstart="{{lastyear}}"   > 1 year</a></li>
                        </ul>
                     </div>

                     <div class='well'>
                        <div id='real_graphs'>
                        </div>
                     </div>
                     
                     <script>
                     $('#tab_to_graphs').on('shown.bs.tab', function (e) {
                        %uris = dict()
                        %uris['4h'] = app.get_graph_uris(elt, fourhours, now)
                        %uris['1d'] = app.get_graph_uris(elt, lastday,   now)
                        %uris['1w'] = app.get_graph_uris(elt, lastweek,  now)
                        %uris['1m'] = app.get_graph_uris(elt, lastmonth, now)
                        %uris['1y'] = app.get_graph_uris(elt, lastyear,  now)

                        // let's create the html content for each time range
                        var element='/{{elt_type}}/{{elt.get_full_name()}}';
                        %for period in ['4h', '1d', '1w', '1m', '1y']:
                        
                        html_graphes['{{period}}'] = '<p>';
                        %for g in uris[period]:
                        %(img_src, link) = app.get_graph_img_src( g['img_src'], g['link'])
                        
                        // Adjust image width / height parameter ... width is sized to container, and height is 1/3
                        var img_src = "{{img_src}}".replace("'","\'")
                        img_src = img_src.replace(/(width=).*?(&)/,'$1' + $('#real_graphs').width() + '$2');
                        img_src = img_src.replace(/(height=).*?(&)/,'$1' + ($('#real_graphs').width() / 3) + '$2');
                        
                        html_graphes['{{period}}'] +=  '<img src="'+ img_src +'" class="jcropelt"/> \
                                                       <a href="{{link}}" target="_blank" class="btn"><i class="fa fa-plus"></i> Show more</a>\
                                                       <a href="javascript:graph_zoom(\''+ element +'\')" class="btn"><i class="icon-zoom-in"></i> Zoom</a>\
                                                       <br>';
                        %end
                        html_graphes['{{period}}'] += '</p>';

                        %end
                        
                        // Set first graph
                        current_graph = '4h';
                     });
                     </script>
                     %end
                  </div>
               </div>
            </div>
            %end
            <!-- Tab Graph end -->

            <!-- Tab Dependency graph Start -->
            %if params['tab_depgraph']=='yes':
            <div class="tab-pane fade" id="depgraph" class="col-lg-12">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} dependency graph:</h4>
                  </div>
     
                  <div class="panel-body">
                     <div class="btn-group btn-group-sm pull-right">
                        <button id="fullscreen-request" class="btn btn-primary"><i class="fa fa-plus"></i> Fullscreen</button>
                     </div>
                     <div id="inner_depgraph" data-elt-name='{{elt.get_full_name()}}'>
                        <span class="alert alert-error">Sorry, I cannot load the dependency graph!</span>
                     </div>
                  </div>
               </div>
            </div>
            %end
            <!-- Tab Dependency graph End -->
        
            <!-- Tab History start -->
            %if params['tab_history']=='yes':
            <div class="tab-pane fade" id="history">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} dependency graph:</h4>
                  </div>
     
                  <div class="panel-body">
                     <div id="inner_history" data-elt-name='{{elt.get_full_name()}}'>
                        <div class="alert alert-danger">
                           <p class="font-red">Sorry, I cannot load the {{elt_type}} history!</p>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            %end
            <!-- Tab History end -->
        
            <!-- Tab Counters start -->
            %if params['tab_counters']=='yes':
            <div class="tab-pane fade" id="counters">
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <h4>{{elt_type.capitalize()}} dependency graph:</h4>
                  </div>
     
                  <div class="panel-body">
                     <div class="row-fluid well col-lg-12">
                        %entity = '-1'
                        %try:
                        %entity = elt.customs['_ENTITIESID']
                        %except Exception:
                        %pass
                        %end

                        <div id="inner_counters" data-elt-name="{{elt.get_full_name()}}" data-elt-entity="{{entity}}">
                           <div class="alert alert-danger">
                              <p class="font-red">Sorry, I cannot load the {{elt_type}} counters!</p>
                              <p class="font-red">({{elt_type}} entity is: {{entity}})</p>
                           </div>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            %end
            <!-- Tab Counters end -->
         </div>
      <!-- Detail info box end -->
   </div>
</div>

<script type="text/javascript">
   on_page_refresh();
</script>
%#End of the element exist or not case
%end
