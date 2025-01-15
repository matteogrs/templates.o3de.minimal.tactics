-- Copyright (c) 2025 Matteo Grasso
-- 
--     https://github.com/matteogrs/templates.o3de.minimal.tactics
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local Select =
{
	Properties =
	{
		MeshId = EntityId(),

		Events =
		{
			SelectRequestEvents = ScriptEventsAssetRef()
		}
	}
}

function Select:OnActivate()
	self.selectHandler = SelectRequestEvents.Connect(self)

	self:HideMarker()
end

function Select:HideMarker()
	RenderMeshComponentRequestBus.Event.SetVisibility(self.Properties.MeshId, false)
end

function Select:ShowMarker()
	RenderMeshComponentRequestBus.Event.SetVisibility(self.Properties.MeshId, true)
end

function Select:SelectEntity(entityId)
	local position = TransformBus.Event.GetWorldTranslation(entityId)

	TransformBus.Event.SetWorldTranslation(self.entityId, position)
end

function Select:OnDeactivate()
	self.selectHandler:Disconnect()
end

return Select
